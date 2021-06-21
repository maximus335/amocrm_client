# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

# AmocrmClient connection
module AmocrmClient
  class Connection
    SUCCESS_STATUS_CODES = [200, 204, 201].freeze

    ERROR_MAP = {
      301 => ::AmocrmClient::AmoMovedPermanentlyError,
      400 => ::AmocrmClient::AmoBadRequestError,
      401 => ::AmocrmClient::AmoUnauthorizedError,
      403 => ::AmocrmClient::AmoForbiddenError,
      404 => ::AmocrmClient::AmoNotFoundError,
      500 => ::AmocrmClient::AmoInternalError,
      502 => ::AmocrmClient::AmoBadGatewayError,
      503 => ::AmocrmClient::AmoServiceUnaviableError,
      429 => ::AmocrmClient::AmoRequestsPerSecExceeded
    }.freeze

    attr_reader :connect, :redlock, :config, :stor_token

    def initialize(config)
      @config = config
      @stor_token = AmocrmClient::StorTokens.new(config)
      @redlock = Redlock.new(config)
      @connect = create_connection
    end

    def create_connection
      Faraday.new(url: config.client['api_endpoint']) do |faraday|
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
        faraday.authorization :Bearer, access_token
      end
    end

    def access_token
      stor_token.find['access_token']
    end

    def request(method, path, params = {})
      url = config.client['api_path'] + path
      redlock.with_redlock { public_send(method, url, params) }
    rescue ::AmocrmClient::AmoUnauthorizedError
      redlock.refresh_with_redlock { refreshing_token }
      reconnect
      redlock.with_redlock { public_send(method, url, params) }
    end

    def refreshing_token
      response = post(config.oauth['path'], refresh_params)
      stor_token.update(refresh_token: response['refresh_token'], access_token: response['access_token'])
    end

    def reconnect
      @connect = create_connection
    end

    def refresh_params
      {
        client_id: config.oauth['client_id'],
        client_secret: config.oauth['client_secret'],
        grant_type: 'refresh_token',
        refresh_token: stor_token.find['refresh_token'],
        redirect_uri: config.oauth['redirect_uri']
      }
    end

    def get(url, params)
      response = connect.get(url, params)
      handle_response(response)
    end

    def post(url, params)
      response = connect.post(url) do |request|
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end

      handle_response(response)
    end

    def patch(url, params)
      response = connect.patch(url) do |request|
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end

      handle_response(response)
    end

    def handle_response(response)
      return response.body if SUCCESS_STATUS_CODES.include?(response.status)

      error = ERROR_MAP[response.status] || ::AmocrmClient::AmoUnknownError

      raise error, response.body
    end
  end
end
