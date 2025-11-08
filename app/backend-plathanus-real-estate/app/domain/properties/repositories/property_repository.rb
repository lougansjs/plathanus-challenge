# frozen_string_literal: true

module Properties
  module Repositories
    class PropertyRepository
      def find(id)
        raise NotImplementedError, "Subclasses must implement #find"
      end

      def all(filters: {}, order: { created_at: :desc }, page: 1, per_page: 12)
        raise NotImplementedError, "Subclasses must implement #all"
      end

      def create(property)
        raise NotImplementedError, "Subclasses must implement #create"
      end

      def update(property)
        raise NotImplementedError, "Subclasses must implement #update"
      end

      def delete(id)
        raise NotImplementedError, "Subclasses must implement #delete"
      end

      def delete_photo(property_id, signed_id)
        raise NotImplementedError, "Subclasses must implement #delete_photo"
      end
    end
  end
end