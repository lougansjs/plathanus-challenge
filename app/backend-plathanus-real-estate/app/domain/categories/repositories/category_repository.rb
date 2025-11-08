# frozen_string_literal: true

module Categories
  module Repositories
    class CategoryRepository
      def find(id)
        raise NotImplementedError
      end

      def all
        raise NotImplementedError
      end

      def create(category)
        raise NotImplementedError
      end
    end
  end
end