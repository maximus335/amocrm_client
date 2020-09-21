# frozen_string_literal: true

module AmocrmClient
  module StorAdapters
    module Redis
      extend self

      def update(params)
        tokens_set(params)
      end

      def find
        tokens = AmocrmClient.redis_connection.hgetall(redis_key)
        tokens.empty? ? nil : tokens
      end

      def create(params)
        tokens_set(params)
      end

      private

      def redis_key
        @redis_key ||= AmocrmClient.config.stor_adapter.dig('redis', 'key')
      end

      def tokens_set(params)
        AmocrmClient.redis_connection.mapped_hmset(redis_key, params)
        params
      end
    end
  end
end
