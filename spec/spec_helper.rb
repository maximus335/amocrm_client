# frozen_string_literal: true

require 'rspec'
require 'amocrm_client'
require 'redis'
require 'webmock/rspec'
require 'mock_redis'
require 'faraday_middleware'

# Cleanup Amorail env
ENV.delete_if { |k, _| k =~ /amocrm_client/i }
ENV["AMOCRM_CLIENT_CONF"] = File.expand_path("fixtures/amocrm_client_test.yml", __dir__)

load_group = lambda do |group|
  Dir["#{__dir__}/#{group}/**/*.rb"].sort.each(&method(:require))
end

%w[support].each(&load_group)

RSpec.configure do |config|
  config.mock_with :rspec
  config.before(:each) do
    mock_redis = MockRedis.new
    allow(Redis).to receive(:new).and_return(mock_redis)
  end
end
