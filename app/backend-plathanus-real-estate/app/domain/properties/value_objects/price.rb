# frozen_string_literal: true

module Properties
  module ValueObjects
    class Price
      attr_reader :value

      def initialize(value)
        @value = validate(value)
      end

      def to_f
        @value
      end

      def to_s
        @value.to_s
      end

      def ==(other)
        other.is_a?(self.class) && @value == other.value
      end

      private

      def validate(value)
        raise ArgumentError, "Price must be a number" unless value.is_a?(Numeric)
        raise ArgumentError, "Price must be greater than or equal to 0" if value.negative?

        value.to_f
      end
    end
  end
end