# frozen_string_literal: true

module AmocrmClient
  module StorAdapters
    class Redis
      def initialize(config)
        @config = config
        @redis_connection = AmocrmClient.redis_connection
      end

      def update(params)
        tokens_set(params)
      end

      def find
        tokens = redis_connection.hgetall(redis_key)
        tokens.empty? ? nil : tokens
      end

      def create(params)
        tokens_set(params)
      end

      private

      attr_reader :config, :redis_connection

      def redis_key
        @redis_key ||= config.stor_adapter.dig('redis', 'key')
      end

      def tokens_set(params)
        redis_connection.mapped_hmset(redis_key, params)
        params
      end
    end
  end
end
