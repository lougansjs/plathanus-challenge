# frozen_string_literal: true

module Properties
  module UseCases
    class ShowProperty
      def initialize(property_repository)
        @property_repository = property_repository
      end

      def execute(id)
        @property_repository.find(id)
      end
    end
  end
end