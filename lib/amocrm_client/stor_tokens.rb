# frozen_string_literal: true

module AmocrmClient
  module StorTokens
    extend self

    ADAPTERS = {
      'ar' => AmocrmClient::StorAdapters::Ar,
      'redis' => AmocrmClient::StorAdapters::Redis
    }.freeze

    def update(data)
      adapter.update(data)
    end

    def find
      adapter.find || adapter.create(init_params)
    end

    def adapter
      @adapter ||= ADAPTERS[AmocrmClient.config.stor_adapter['stor']]
    end

    def init_params
      @init_params ||= {
        'refresh_token' => AmocrmClient.config.oauth['init_refresh_token'],
        'access_token' => AmocrmClient.config.oauth['init_access_token']
      }
    end
  end
end
