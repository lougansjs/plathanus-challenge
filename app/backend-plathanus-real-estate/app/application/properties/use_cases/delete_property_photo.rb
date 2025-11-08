# frozen_string_literal: true

module Properties
  module UseCases
    class DeletePropertyPhoto
      def initialize(property_repository, property_photo_service)
        @property_repository = property_repository
        @property_photo_service = property_photo_service
      end

      def execute(property_id, signed_id)
        property = @property_repository.find(property_id)
        raise ActiveRecord::RecordNotFound, "Property not found" unless property

        remaining_count = property.photos.size - 1
        @property_photo_service.validate_for_delete(remaining_count)

        @property_repository.delete_photo(property_id, signed_id)
      end
    end
  end
end