# frozen_string_literal: true

module Mappers
  class AddressMapper
    def self.to_entity(record)
      return nil unless record

      ::Properties::Entities::Address.new(
        id: record.id,
        street: record.street,
        neighborhood: record.neighborhood,
        city: record.city,
        state: record.state,
        country: record.country,
        zipcode: record.zipcode,
        latitude: record.latitude,
        longitude: record.longitude
      )
    end

    def self.to_record(entity, record = nil)
      record ||= ::Persistence::Models::AddressRecord.new

      record.street = entity.street
      record.neighborhood = entity.neighborhood
      record.city = entity.city
      record.state = entity.state
      record.country = entity.country
      record.zipcode = entity.zipcode
      record.latitude = entity.latitude
      record.longitude = entity.longitude

      record
    end
  end
end