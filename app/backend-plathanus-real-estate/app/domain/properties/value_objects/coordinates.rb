# frozen_string_literal: true

module Properties
  module ValueObjects
    class Coordinates
      attr_reader :latitude, :longitude

      def initialize(latitude:, longitude:)
        @latitude = validate_latitude(latitude)
        @longitude = validate_longitude(longitude)
      end

      def ==(other)
        other.is_a?(self.class) &&
          @latitude == other.latitude &&
          @longitude == other.longitude
      end

      private

      def validate_latitude(value)
        return nil if value.nil?

        lat = value.to_f
        raise ArgumentError, "Latitude must be between -90 and 90" unless lat.between?(-90, 90)

        lat
      end

      def validate_longitude(value)
        return nil if value.nil?

        lng = value.to_f
        raise ArgumentError, "Longitude must be between -180 and 180" unless lng.between?(-180, 180)

        lng
      end
    end
  end
end