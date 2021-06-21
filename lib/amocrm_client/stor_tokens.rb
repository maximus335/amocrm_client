# frozen_string_literal: true

module AmocrmClient
  class StorTokens
    ADAPTERS = {
      'ar' => AmocrmClient::StorAdapters::Ar,
      'redis' => AmocrmClient::StorAdapters::Redis
    }.freeze

    attr_reader :adapter

    def initialize(config)
      @config = config
      @adapter = ADAPTERS[config.stor_adapter['stor']].new(config)
    end

    def update(data)
      adapter.update(data)
    end

    def find
      adapter.find || adapter.create(init_params)
    end

    def init_params
      @init_params ||= {
        'refresh_token' => @config.oauth['init_refresh_token'],
        'access_token' => @config.oauth['init_access_token']
      }
    end
  end
end
