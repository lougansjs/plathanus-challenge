# frozen_string_literal: true

module Properties
  module Entities
    class Property
      attr_accessor :id, :name, :code, :rooms, :bathrooms, :area, :parking_slots,
                    :furnished, :description, :promotional_price, :available_from,
                    :rooms_list, :apartment_amenities, :building_characteristics,
                    :category_id, :category, :address, :photos, :created_at
      attr_reader :status, :contract_type, :price

      def initialize(
        id: nil,
        name: nil,
        code: nil,
        status: nil,
        rooms: nil,
        bathrooms: nil,
        area: nil,
        parking_slots: nil,
        furnished: false,
        contract_type: nil,
        description: nil,
        price: nil,
        promotional_price: nil,
        available_from: nil,
        rooms_list: [],
        apartment_amenities: [],
        building_characteristics: [],
        category_id: nil,
        category: nil,
        address: nil,
        photos: [],
        created_at: nil
      )
        @id = id
        @name = name
        @code = code
        self.status = status if status
        @rooms = rooms
        @bathrooms = bathrooms
        @area = area
        @parking_slots = parking_slots
        @furnished = furnished
        self.contract_type = contract_type if contract_type
        @description = description
        self.price = price if price
        @promotional_price = promotional_price
        @available_from = available_from
        @rooms_list = Array(rooms_list)
        @apartment_amenities = validate_amenities(apartment_amenities)
        @building_characteristics = validate_characteristics(building_characteristics)
        @category_id = category_id
        @category = category
        @address = address
        @photos = Array(photos)
        @created_at = created_at
      end

      def status_value
        @status&.to_s
      end

      def status=(value)
        @status = value.is_a?(::Properties::ValueObjects::PropertyStatus) ? value : ::Properties::ValueObjects::PropertyStatus.new(value)
      end

      def contract_type_value
        @contract_type&.to_s
      end

      def contract_type=(value)
        @contract_type = value.is_a?(::Properties::ValueObjects::ContractType) ? value : ::Properties::ValueObjects::ContractType.new(value)
      end

      def price_value
        @price&.to_f
      end

      def price=(value)
        @price = value.is_a?(::Properties::ValueObjects::Price) ? value : ::Properties::ValueObjects::Price.new(value.to_f)
      end

      def cover_photo
        @photos[2]
      end

      def apartment_amenities=(values)
        @apartment_amenities = validate_amenities(values)
      end

      def building_characteristics=(values)
        @building_characteristics = validate_characteristics(values)
      end

      private

      def validate_amenities(values)
        return [] if values.nil? || values.empty?

        ::Properties::ValueObjects::ApartmentAmenity.validate_array(values)
      end

      def validate_characteristics(values)
        return [] if values.nil? || values.empty?

        ::Properties::ValueObjects::BuildingCharacteristic.validate_array(values)
      end
    end
  end
end