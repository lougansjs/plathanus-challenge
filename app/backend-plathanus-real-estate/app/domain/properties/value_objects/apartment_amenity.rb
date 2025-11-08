# frozen_string_literal: true

module Properties
  module ValueObjects
    class ApartmentAmenity
      VALID_AMENITIES = %w[
        wifi
        smart_tv
        air_conditioning
        oven
        microwave
        stove
        linen_towels
        kitchen
        balcony
        washer_dryer
      ].freeze

      attr_reader :value

      def initialize(value)
        @value = validate(value)
      end

      def to_s
        @value
      end

      def ==(other)
        other.is_a?(self.class) && @value == other.value
      end

      def self.valid?(value)
        VALID_AMENITIES.include?(value.to_s)
      end

      def self.validate_array(values)
        return [] if values.nil? || values.empty?

        invalid = Array(values).map(&:to_s) - VALID_AMENITIES
        raise ArgumentError, "Invalid apartment amenities: #{invalid.join(', ')}" if invalid.any?

        Array(values).map(&:to_s)
      end

      private

      def validate(value)
        raise ArgumentError, "Invalid apartment amenity: #{value}" unless VALID_AMENITIES.include?(value.to_s)

        value.to_s
      end
    end
  end
end

