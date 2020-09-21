# frozen_string_literal: true

require 'redlock'

module AmocrmClient
  class Redlock
    RESOURCE = 'amocrm_lock_resource'
    REQUESTS = 'amocrm_request_times'
    REFRESH_RESOURCE = 'amocrm_refresh_token_resource'
    REFRESH_TIME = 'refresh_time'
    BASE_EXPIRES_IN = 86400

    def initialize
      @redis_connection = AmocrmClient.redis_connection
      @lock_manager = ::Redlock::Client.new([AmocrmClient.config.redis['url']])
      @request_number = AmocrmClient.config.client['request_number']
    end

    def with_redlock
      lock_resource = @lock_manager.lock(RESOURCE, 1000) until lock_resource

      request_delta
      @lock_manager.unlock(lock_resource)
      yield
    end

    def refresh_with_redlock
      lock_resource = @lock_manager.lock(REFRESH_RESOURCE, 3000)

      if lock_resource
        return if refresh_already?
        @redis_connection.set(REFRESH_TIME, Time.now.utc.to_f)
        yield
        @lock_manager.unlock(lock_resource)
      else
        nil
      end
    end

    private

    def request_delta
      if resource_len == @request_number
        first_time = @redis_connection.lpop(REQUESTS).to_f
        time_now = Time.now.utc.to_f
        wait_time = 1 - (time_now - first_time)
        sleep wait_time if wait_time.positive?
      end

      @redis_connection.rpush(REQUESTS, Time.now.utc.to_f)
    end

    def resource_len
      @redis_connection.llen(REQUESTS)
    end



    def refresh_already?
      last_refresh = @redis_connection.get(REFRESH_TIME).to_f
      delta = Time.now.utc.to_f - last_refresh
      delta < expires_in
    end

    def expires_in
      AmocrmClient.config.oauth['expires_in'] || BASE_EXPIRES_IN
    end
  end
end
