# frozen_string_literal: true

require 'anyway'

# AmocrmClient config
module AmocrmClient
  class Config < Anyway::Config
    config_name :amocrm_client
    attr_config :client, :oauth, :stor_adapter, :redis
  end
end
