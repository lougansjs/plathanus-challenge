# frozen_string_literal: true

module Properties
  module UseCases
    class DeleteProperty
      def initialize(property_repository)
        @property_repository = property_repository
      end

      def execute(id)
        @property_repository.delete(id)
      end
    end
  end
end