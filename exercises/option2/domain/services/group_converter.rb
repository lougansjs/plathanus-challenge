# frozen_string_literal: true

module Domain
  module Services
    # Classe responsável por converter um grupo de 3 dígitos em texto
    class GroupConverter
      def initialize(vocabulary_provider)
        @vocabulary_provider = vocabulary_provider
      end

      def convert(group)
        return '' if group.zero?

        parts = []
        parts << hundreds_text(group)
        parts << tens_and_units_text(group.tens_and_units)

        join_group_parts(parts)
      end

      private

      def hundreds_text(group)
        hundreds = group.hundreds
        return '' if hundreds.zero?

        group.one_hundred? ? 'cem' : @vocabulary_provider.hundreds[hundreds]
      end

      # rubocop:disable Metrics/MethodLength
      def tens_and_units_text(remainder)
        return '' if remainder.zero?

        case remainder
        when 0..9
          @vocabulary_provider.units[remainder]
        when 10..19
          @vocabulary_provider.special_tens[remainder - 10]
        when 20..99
          ten = remainder / 10
          unit = remainder % 10

          parts = [@vocabulary_provider.tens[ten]]
          parts << @vocabulary_provider.units[unit] if unit.positive?
          parts.join(' e ')
        end
      end
      # rubocop:enable Metrics/MethodLength

      def join_group_parts(parts)
        parts.reject(&:empty?).join(' e ')
      end
    end
  end
end
