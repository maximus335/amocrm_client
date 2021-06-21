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
    @connection ||= Connection.new(AmocrmClient.config)
  end

  def redis_connection
    @redis_connection ||= Redis.new(url: AmocrmClient.config.redis['url'])
  end

  def configure
    yield(config) if block_given?
  end

  def accounts
    return @accounts if defined?(@accounts)

    AmocrmClient.config.accounts&.keys&.each do |account|
      define_method("connection_#{account}") do
        return @account_connection if defined?(@account_connection)

        @account_connection = Connection.new(OpenStruct.new(AmocrmClient.config.accounts[account]))
      end
    end
    @accounts = self
  end
end
