# frozen_string_literal: true

module Properties
  module UseCases
    class UpdateProperty
      def initialize(property_repository, property_photo_service)
        @property_repository = property_repository
        @property_photo_service = property_photo_service
      end

      def execute(id, dto, address_params, new_photos)
        property = @property_repository.find(id)
        raise ActiveRecord::RecordNotFound, "Property not found" unless property

        # Validar quantidade de fotos se houver novas
        if new_photos.present?
          existing_count = property.photos.size
          @property_photo_service.validate_for_update(existing_count, new_photos)
        end

        # Atualizar atributos
        property.name = dto.name if dto.name
        property.status = ::Properties::ValueObjects::PropertyStatus.new(dto.status) if dto.status
        property.category_id = dto.category_id if dto.category_id
        property.rooms = dto.rooms if dto.rooms
        property.bathrooms = dto.bathrooms if dto.bathrooms
        property.area = dto.area if dto.area
        property.parking_slots = dto.parking_slots if dto.parking_slots
        property.furnished = dto.furnished unless dto.furnished.nil?
        property.contract_type = ::Properties::ValueObjects::ContractType.new(dto.contract_type) if dto.contract_type
        property.description = dto.description if dto.description
        property.price = ::Properties::ValueObjects::Price.new(dto.price.to_f) if dto.price
        property.promotional_price = dto.promotional_price if dto.promotional_price
        property.available_from = dto.available_from if dto.available_from
        property.rooms_list = dto.rooms_list if dto.rooms_list
        property.apartment_amenities = dto.apartment_amenities if dto.apartment_amenities
        property.building_characteristics = dto.building_characteristics if dto.building_characteristics

        # Atualizar endereço se fornecido
        if address_params
          if property.address
            property.address.street = address_params[:street] if address_params[:street]
            property.address.neighborhood = address_params[:neighborhood] if address_params[:neighborhood]
            property.address.city = address_params[:city] if address_params[:city]
            property.address.state = address_params[:state] if address_params[:state]
            property.address.country = address_params[:country] if address_params[:country]
            property.address.zipcode = address_params[:zipcode] if address_params[:zipcode]
            if address_params[:latitude] || address_params[:longitude]
              property.address.coordinates = ::Properties::ValueObjects::Coordinates.new(
                latitude: address_params[:latitude] || property.address.latitude,
                longitude: address_params[:longitude] || property.address.longitude
              )
            end
          else
            property.address = ::Properties::Entities::Address.new(
              street: address_params[:street],
              neighborhood: address_params[:neighborhood],
              city: address_params[:city],
              state: address_params[:state],
              country: address_params[:country],
              zipcode: address_params[:zipcode],
              latitude: address_params[:latitude],
              longitude: address_params[:longitude]
            )
          end
        end

        @property_repository.update(property, photos: new_photos)
      end
    end
  end
end