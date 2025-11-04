# frozen_string_literal: true

module Application
  module UseCases
    # Use case responsável por converter um número para romanos
    class ConvertNumberToRoman
      def initialize(roman_converter, overline_formatter)
        @roman_converter = roman_converter
        @overline_formatter = overline_formatter
      end

      def call(number)
        number_entity = Option1::Domain::Entities::Number.new(number)

        if number_entity.value >= 4_000
          major_value, minor_value = number_entity.value.divmod(1000)
          major_roman = @roman_converter.convert(major_value)
          formatted_major = @overline_formatter.format(major_roman)

          minor_part = minor_value.positive? ? @roman_converter.convert(minor_value) : ''

          formatted_major + minor_part
        else
          @roman_converter.convert(number_entity.value)
        end
      end
    end
  end
end
