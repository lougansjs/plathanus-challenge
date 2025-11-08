# frozen_string_literal: true

module Properties
  module UseCases
    class CreateProperty
      def initialize(property_repository, property_photo_service)
        @property_repository = property_repository
        @property_photo_service = property_photo_service
      end

      def execute(dto, address_params, photos)
        # Validar quantidade de fotos
        @property_photo_service.validate_for_create(photos)

        # Criar entidade de domínio
        property = ::Properties::Entities::Property.new(
          name: dto.name,
          status: dto.status,
          category_id: dto.category_id,
          rooms: dto.rooms,
          bathrooms: dto.bathrooms,
          area: dto.area,
          parking_slots: dto.parking_slots,
          furnished: dto.furnished,
          contract_type: dto.contract_type,
          description: dto.description,
          price: dto.price,
          promotional_price: dto.promotional_price,
          available_from: dto.available_from,
          rooms_list: dto.rooms_list,
          apartment_amenities: dto.apartment_amenities,
          building_characteristics: dto.building_characteristics
        )

        # Criar endereço se fornecido
        if address_params
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

        # Salvar no repositório (que anexará as fotos)
        @property_repository.create(property, photos: photos)
      end
    end
  end
end