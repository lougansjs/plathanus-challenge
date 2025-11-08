# frozen_string_literal: true

module Properties
  module UseCases
    class ListProperties
      def initialize(property_repository, filter_service)
        @property_repository = property_repository
        @filter_service = filter_service
      end

      def execute(filter_dto)
        filters = @filter_service.build_filters(
          search: filter_dto.search,
          city: filter_dto.city,
          rooms: filter_dto.rooms,
          rooms_min: filter_dto.rooms_min,
          bathrooms: filter_dto.bathrooms,
          parking_slots: filter_dto.parking_slots,
          price_min: filter_dto.price_min,
          price_max: filter_dto.price_max,
          furnished: filter_dto.furnished,
          apartment_amenities: filter_dto.apartment_amenities,
          building_characteristics: filter_dto.building_characteristics,
          pets_allowed: filter_dto.pets_allowed
        )

        order = @filter_service.build_order(filter_dto.order)

        result = @property_repository.all(
          filters: filters,
          order: order,
          page: filter_dto.page,
          per_page: filter_dto.per_page
        )

        {
          properties: result[:properties],
          meta: result[:meta]
        }
      end
    end
  end
end