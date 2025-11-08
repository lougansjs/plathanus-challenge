# frozen_string_literal: true

module Categories
  module UseCases
    class ListCategories
      def initialize(category_repository)
        @category_repository = category_repository
      end

      def execute
        @category_repository.all
      end
    end
  end
end