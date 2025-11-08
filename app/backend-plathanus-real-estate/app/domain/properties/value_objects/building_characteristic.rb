# frozen_string_literal: true

module Properties
  module ValueObjects
    class BuildingCharacteristic
      VALID_CHARACTERISTICS = %w[
        parking
        pets_allowed
        gym
        gated_building
        breakfast
        sauna
        elevator
        doorman
        coworking
        pool
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
        VALID_CHARACTERISTICS.include?(value.to_s)
      end

      def self.validate_array(values)
        return [] if values.nil? || values.empty?

        invalid = Array(values).map(&:to_s) - VALID_CHARACTERISTICS
        raise ArgumentError, "Invalid building characteristics: #{invalid.join(', ')}" if invalid.any?

        Array(values).map(&:to_s)
      end

      private

      def validate(value)
        raise ArgumentError, "Invalid building characteristic: #{value}" unless VALID_CHARACTERISTICS.include?(value.to_s)

        value.to_s
      end
    end
  end
end

