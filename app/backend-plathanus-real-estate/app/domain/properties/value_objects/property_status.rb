# frozen_string_literal: true

module Properties
  module ValueObjects
    class PropertyStatus
      VALID_STATUSES = %w[available unavailable rented maintenance archived].freeze

      attr_reader :value

      def initialize(value)
        @value = validate(value)
      end

      def to_s
        @value
      end

      def available?
        @value == "available"
      end

      def unavailable?
        @value == "unavailable"
      end

      def rented?
        @value == "rented"
      end

      def maintenance?
        @value == "maintenance"
      end

      def archived?
        @value == "archived"
      end

      def ==(other)
        other.is_a?(self.class) && @value == other.value
      end

      private

      def validate(value)
        raise ArgumentError, "Invalid status: #{value}" unless VALID_STATUSES.include?(value.to_s)

        value.to_s
      end
    end
  end
end