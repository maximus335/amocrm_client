# frozen_string_literal: true

require 'redlock'

module AmocrmClient
  class Redlock
    RESOURCE = 'amocrm_lock_resource'
    REQUESTS = 'amocrm_request_times'
    REFRESH_RESOURCE = 'amocrm_refresh_token_resource'
    REFRESH_TIME = 'refresh_time'
    BASE_EXPIRES_IN = 86_400

    def initialize(config)
      @redis_connection = AmocrmClient.redis_connection
      @lock_manager = ::Redlock::Client.new([AmocrmClient.config.redis['url']])
      @request_number = config.client['request_number']
      @expires_in = config.oauth['expires_in']
      @client_endpoint = config.client['api_endpoint']
    end

    def with_redlock
      lock_resource = @lock_manager.lock("#{@client_endpoint}#{RESOURCE}", 1000) until lock_resource

      request_delta
      @lock_manager.unlock(lock_resource)
      yield
    end

    def refresh_with_redlock
      lock_resource = @lock_manager.lock("#{@client_endpoint}#{REFRESH_RESOURCE}", 3000)

      return unless lock_resource
      return if refresh_already?

      @redis_connection.set("#{@client_endpoint}#{REFRESH_TIME}", Time.now.utc.to_f)
      yield
      @lock_manager.unlock(lock_resource)
    end

    private

    def request_delta
      if resource_len == @request_number
        wait_request_process
      elsif resource_len > @request_number
        @redis_connection.ltrim("#{@client_endpoint}#{REQUESTS}", -@request_number, -1)
        wait_request_process
      end

      @redis_connection.rpush("#{@client_endpoint}#{REQUESTS}", Time.now.utc.to_f)
    end

    def wait_request_process
      first_time = @redis_connection.lpop("#{@client_endpoint}#{REQUESTS}").to_f
      time_now = Time.now.utc.to_f
      wait_time = 1 - (time_now - first_time)
      sleep wait_time if wait_time.positive?
    end

    def resource_len
      @redis_connection.llen("#{@client_endpoint}#{REQUESTS}")
    end

    def refresh_already?
      last_refresh = @redis_connection.get("#{@client_endpoint}#{REFRESH_TIME}").to_f
      delta = Time.now.utc.to_f - last_refresh
      delta < expires_in
    end

    def expires_in
      @expires_in || BASE_EXPIRES_IN
    end
  end
end
