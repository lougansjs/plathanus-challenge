# frozen_string_literal: true

module ParameterHelpers
  extend ActiveSupport::Concern

  private

  # Converte string para integer de forma segura
  def safe_integer(value)
    return nil if value.blank?

    Integer(value)
  rescue ArgumentError, TypeError
    nil
  end

  # Converte string para float de forma segura
  def safe_float(value)
    return nil if value.blank?

    Float(value)
  rescue ArgumentError, TypeError
    nil
  end

  # Sanitiza array de amenities contra whitelist
  def sanitize_amenities(array)
    return [] if array.blank?

    valid_array = Array(array).select { |item| ::Properties::ValueObjects::ApartmentAmenity.valid?(item) }
    valid_array.map(&:to_s)
  end

  # Sanitiza array de characteristics contra whitelist
  def sanitize_characteristics(array)
    return [] if array.blank?

    valid_array = Array(array).select { |item| ::Properties::ValueObjects::BuildingCharacteristic.valid?(item) }
    valid_array.map(&:to_s)
  end
end

