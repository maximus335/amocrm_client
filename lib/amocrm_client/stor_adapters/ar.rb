# frozen_string_literal: true

module AmocrmClient
  module StorAdapters
    module Ar
      extend self

      def update(data)
        model.last.update(data)
      end

      def find
        model.last
      end

      def create(params)
        model.create!(params)
      end

      private

      def model
        @model ||= AmocrmClient.config.stor_adapter.dig('ar', 'model_name').constantize
      end
    end
  end
end
