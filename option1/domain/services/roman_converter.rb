# frozen_string_literal: true

module Domain
  module Services
    # Classe responsável por converter um número para romanos
    class RomanConverter
      def initialize(roman_table_provider)
        @roman_table_provider = roman_table_provider
      end

      def convert(number)
        roman = String.new
        @roman_table_provider.symbols.each do |value, symbol|
          while number >= value
            number -= value
            roman << symbol
          end
        end

        roman
      end
    end
  end
end
