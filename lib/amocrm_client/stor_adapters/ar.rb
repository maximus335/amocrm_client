# frozen_string_literal: true

module AmocrmClient
  module StorAdapters
    class Ar
      def initialize(config)
        @model = config.stor_adapter.dig('ar', 'model_name').constantize
      end

      def update(data)
        @model.last.update(data)
      end

      def find
        @model.last
      end

      def create(params)
        @model.create!(params)
      end
    end
  end
end
