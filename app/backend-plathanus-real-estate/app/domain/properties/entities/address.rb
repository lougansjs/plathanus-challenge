# frozen_string_literal: true

module Properties
  module Entities
    class Address
      include ActiveModel::Model
      include ActiveModel::Serialization

      attr_accessor :id, :street, :neighborhood, :city, :state, :country, :zipcode
      attr_reader :coordinates

      def initialize(
        id: nil,
        street: nil,
        neighborhood: nil,
        city: nil,
        state: nil,
        country: nil,
        zipcode: nil,
        latitude: nil,
        longitude: nil
      )
        @id = id
        @street = street
        @neighborhood = neighborhood
        @city = city
        @state = state
        @country = country
        @zipcode = zipcode
        @coordinates = ::Properties::ValueObjects::Coordinates.new(latitude: latitude, longitude: longitude) if latitude || longitude
      end

      def latitude
        @coordinates&.latitude
      end

      def longitude
        @coordinates&.longitude
      end

      def coordinates=(value)
        @coordinates = value
      end

      def valid?
        [street, neighborhood, city, state, country, zipcode].all?(&:present?)
      end
    end
  end
end