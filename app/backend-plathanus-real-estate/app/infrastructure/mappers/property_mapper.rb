# frozen_string_literal: true

module Mappers
  class PropertyMapper
    def self.to_entity(record)
      return nil unless record

      ::Properties::Entities::Property.new(
        id: record.id,
        name: record.name,
        code: record.code,
        status: record.status,
        rooms: record.rooms,
        bathrooms: record.bathrooms,
        area: record.area,
        parking_slots: record.parking_slots,
        furnished: record.furnished,
        contract_type: record.contract_type,
        description: record.description,
        price: record.price,
        promotional_price: record.promotional_price,
        available_from: record.available_from,
        rooms_list: record.rooms_list || [],
        apartment_amenities: record.apartment_amenities || [],
        building_characteristics: record.building_characteristics || [],
        category_id: record.category_id,
        category: record.category ? ::Mappers::CategoryMapper.to_entity(record.category) : nil,
        address: record.address ? ::Mappers::AddressMapper.to_entity(record.address) : nil,
        photos: record.photos.attached? ? record.photos_attachments.to_a : [],
        created_at: record.created_at
      )
    end

    def self.to_record(entity, record = nil)
      record ||= ::Persistence::Models::PropertyRecord.new

      record.name = entity.name
      record.code = entity.code
      record.status = entity.status_value
      record.rooms = entity.rooms
      record.bathrooms = entity.bathrooms
      record.area = entity.area
      record.parking_slots = entity.parking_slots
      record.furnished = entity.furnished
      record.contract_type = entity.contract_type_value
      record.description = entity.description
      record.price = entity.price_value
      record.promotional_price = entity.promotional_price
      record.available_from = entity.available_from
      record.rooms_list = entity.rooms_list
      record.apartment_amenities = entity.apartment_amenities
      record.building_characteristics = entity.building_characteristics
      record.category_id = entity.category_id

      record
    end

    def self.to_dto(entity)
      return nil unless entity

      ::Properties::Dto::PropertyDto.new(entity)
    end
  end
end