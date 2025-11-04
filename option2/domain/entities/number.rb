# frozen_string_literal: true

module Option2
  module Domain
    module Entities
      # Classe responsável por representar um número
      class Number
        attr_reader :value

        def initialize(value)
          validate_input!(value)

          @value = value
        end

        def zero?
          @value.zero?
        end

        def split_into_groups
          @value.to_s.reverse.scan(/.{1,3}/).map do |group|
            ::Domain::ValueObjects::NumberGroup.new(value: group.reverse.to_i)
          end.reverse
        end

        private

        def validate_input!(value)
          unless value.is_a?(Integer) && value >= 0
            raise ArgumentError, 'Número inválido: deve ser um número natural (>= 0)'
          end

          unless value < 1_000_000_000_000_000
            raise ArgumentError, 'Número inválido: não é possível converter número maior que 999.999.999.999.999'
          end
        end
      end
    end
  end
end
