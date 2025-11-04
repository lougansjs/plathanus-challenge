# frozen_string_literal: true

module Domain
  module ValueObjects
    # Classe responsável por representar um grupo de 3 dígitos
    class NumberGroup
      attr_reader :value

      def initialize(value:)
        validate_input!(value)

        @value = value
      end

      def zero?
        @value.zero?
      end

      def ==(other)
        other.is_a?(self.class) && other.value == @value
      end

      private

      def validate_input!(value)
        unless (0..999).include?(value)
          raise ArgumentError, 'Grupo deve estar entre 0 e 999'
        end
      end
    end
  end
end
