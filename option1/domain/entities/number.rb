# frozen_string_literal: true

module Option1
  module Domain
    module Entities
      # Classe responsável por representar um número
      class Number
        attr_reader :value

        MAX_VALUE = 3_999_999

        def initialize(value)
          validate_input!(value)

          @value = value
        end

        private

        def validate_input!(value)
          unless value.is_a?(Integer) && value.positive?
            raise ArgumentError, 'Número inválido: deve ser um número natural (> 0)'
          end

          if value > MAX_VALUE
            raise ArgumentError, "Número inválido: não é possível converter número maior que #{MAX_VALUE}"
          end
        end
      end
    end
  end
end
