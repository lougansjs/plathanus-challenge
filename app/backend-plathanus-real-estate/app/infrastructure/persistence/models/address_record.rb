# frozen_string_literal: true

module Persistence
  module Models
    class AddressRecord < ApplicationRecord
      self.table_name = "addresses"

      belongs_to :property, class_name: "Persistence::Models::PropertyRecord", foreign_key: "property_id"

      validates :street, :neighborhood, :city, :state, :country, :zipcode, presence: true
      validates :latitude, numericality: {
        allow_nil: true,
        greater_than_or_equal_to: -90,
        less_than_or_equal_to: 90
      }
      validates :longitude, numericality: {
        allow_nil: true,
        greater_than_or_equal_to: -180,
        less_than_or_equal_to: 180
      }
    end
  end
end