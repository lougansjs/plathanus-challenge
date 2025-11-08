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

      # Retorna as centenas do grupo (0-9)
      def hundreds
        @value / 100
      end

      # Retorna dezenas e unidades (0-99)
      def tens_and_units
        @value % 100
      end

      # Verifica se o grupo é igual a 1
      def one?
        @value == 1
      end

      # Verifica se o grupo é igual a 100
      def one_hundred?
        @value == 100
      end

      # Compara se o grupo é menor ou igual a um valor
      def <=(other)
        comparison_value = other.is_a?(Integer) ? other : other.value
        @value <= comparison_value
      end

      # Compara se o grupo é menor que um valor
      def <(other)
        comparison_value = other.is_a?(Integer) ? other : other.value
        @value < comparison_value
      end

      # Compara se o grupo é maior ou igual a um valor
      def >=(other)
        comparison_value = other.is_a?(Integer) ? other : other.value
        @value >= comparison_value
      end

      # Compara se o grupo é maior que um valor
      def >(other)
        comparison_value = other.is_a?(Integer) ? other : other.value
        @value > comparison_value
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
