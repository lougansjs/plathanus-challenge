# frozen_string_literal: true

module Properties
  module ValueObjects
    class ContractType
      VALID_TYPES = %w[rent].freeze

      attr_reader :value

      def initialize(value)
        @value = validate(value)
      end

      def to_s
        @value
      end

      def rent?
        @value == "rent"
      end

      def ==(other)
        other.is_a?(self.class) && @value == other.value
      end

      private

      def validate(value)
        raise ArgumentError, "Invalid contract type: #{value}" unless VALID_TYPES.include?(value.to_s)

        value.to_s
      end
    end
  end
end