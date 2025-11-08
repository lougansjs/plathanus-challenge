# frozen_string_literal: true

module Properties
  module Dto
    class PropertyDto
      include ActiveModel::Model
      include ActiveModel::Serialization

      attr_accessor :id, :name, :code, :status, :rooms, :bathrooms, :area, :parking_slots,
                    :furnished, :contract_type, :description, :price, :promotional_price,
                    :available_from, :rooms_list, :apartment_amenities, :building_characteristics,
                    :category_id, :category, :address, :photos, :cover_photo, :created_at

      def initialize(property_entity)
        @id = property_entity.id
        @name = property_entity.name
        @code = property_entity.code
        @status = property_entity.status_value
        @rooms = property_entity.rooms
        @bathrooms = property_entity.bathrooms
        @area = property_entity.area
        @parking_slots = property_entity.parking_slots
        @furnished = property_entity.furnished
        @contract_type = property_entity.contract_type_value
        @description = property_entity.description
        @price = property_entity.price_value
        @promotional_price = property_entity.promotional_price
        @available_from = property_entity.available_from
        @rooms_list = property_entity.rooms_list
        @apartment_amenities = property_entity.apartment_amenities
        @building_characteristics = property_entity.building_characteristics
        @category_id = property_entity.category_id
        @category = property_entity.category
        @address = property_entity.address
        @photos = property_entity.photos
        @cover_photo = property_entity.cover_photo
        @created_at = property_entity.created_at
      end
    end
  end
end