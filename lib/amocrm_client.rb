# frozen_string_literal: true

require 'amocrm_client/exceptions'
require 'amocrm_client/version'
require 'amocrm_client/config'
require 'amocrm_client/stor_adapters/ar'
require 'amocrm_client/stor_adapters/redis'
require 'amocrm_client/redlock'
require 'amocrm_client/stor_tokens'
require 'amocrm_client/connection'

module AmocrmClient
  extend self

  def config
    @config ||= Config.new
  end

  def connection
    @connection ||= Connection.new
  end

  def configure
    yield(config) if block_given?
  end

  def redlock
    @redlock ||= Redlock.new
  end

  def redis_connection
    @redis_connection ||= Redis.new(url: AmocrmClient.config.redis['url'])
  end
end
