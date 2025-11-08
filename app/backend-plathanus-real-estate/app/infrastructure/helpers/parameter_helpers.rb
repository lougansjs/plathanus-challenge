# frozen_string_literal: true

module Helpers
  module ParameterHelpers
    def safe_integer(value)
      return nil if value.blank?

      Integer(value)
    rescue ArgumentError, TypeError
      nil
    end

    def safe_float(value)
      return nil if value.blank?

      Float(value)
    rescue ArgumentError, TypeError
      nil
    end

    def sanitize_amenities(array)
      return [] if array.blank?

      valid_array = Array(array).select { |item| ::Properties::ValueObjects::ApartmentAmenity.valid?(item) }
      valid_array.map(&:to_s)
    end

    def sanitize_characteristics(array)
      return [] if array.blank?

      valid_array = Array(array).select { |item| ::Properties::ValueObjects::BuildingCharacteristic.valid?(item) }
      valid_array.map(&:to_s)
    end
  end
end