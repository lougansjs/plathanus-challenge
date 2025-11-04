# frozen_string_literal: true

module Application
  module UseCases
    # Use case responsável por converter um número para palavras em português
    class ConvertNumberToWords
      def initialize(vocabulary_provider, group_converter, scale_manager)
        @vocabulary_provider = vocabulary_provider
        @group_converter = group_converter
        @scale_manager = scale_manager
      end

      def call(number)
        number_entity = Option2::Domain::Entities::Number.new(number)
        return @vocabulary_provider.units[0] if number_entity.value.zero?

        groups = number_entity.split_into_groups
        parts = build_parts(groups)
        join_parts(parts)
      end

      private

      # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
      def build_parts(groups)
        parts = []
        groups.each_with_index do |group, index|
          next if group.value.zero?

          scale_index = groups.size - index - 1
          # Regra especial: quando é mil (scale_index == 1) e o grupo é 1, não mostra "um"
          if scale_index == 1 && group.value == 1
            scale_name = @scale_manager.scale_name(group, scale_index)
            parts << {
              text: scale_name,
              has_scale: scale_index.positive?,
              group_value: group.value,
              scale_index: scale_index
            } unless scale_name.empty?
          else
            group_name = @group_converter.convert(group)
            scale_name = @scale_manager.scale_name(group, scale_index)

            part = [group_name, scale_name].reject(&:empty?).join(' ')
            parts << {
              text: part,
              has_scale: scale_index.positive?,
              group_value: group.value,
              scale_index: scale_index
            } unless part.empty?
          end
        end

        parts
      end
      # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize

      # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
      def join_parts(parts)
        return parts.first[:text] if parts.size == 1

        # Extrai os textos
        texts = parts.map { |p| p[:text] }
        has_any_scale = parts.any? { |p| p[:has_scale] }
        scales_count = parts.count { |p| p[:has_scale] }

        if parts.size == 2
          part1, part2 = parts

          if scales_count == 2
            part2_scale_index = part2[:scale_index]
            if part2_scale_index == 1 && part2[:group_value] == 1
              "#{part1[:text]} e #{part2[:text]}"
            else
              texts.join(' ')
            end
          elsif has_any_scale
            scale_part = part1[:has_scale] ? part1 : part2
            group_part = part1[:has_scale] ? part2 : part1

            if group_part[:group_value] <= 100
              "#{scale_part[:text]} e #{group_part[:text]}"
            else
              "#{scale_part[:text]} #{group_part[:text]}"
            end
          else
            texts.join(' e ')
          end
        else
          "#{texts[0..-2].join(', ')} e #{texts[-1]}"
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
    end
  end
end
