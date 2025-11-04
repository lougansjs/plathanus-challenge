# frozen_string_literal: true

module Domain
  module Services
    # Classe responsável por gerenciar escalas (mil, milhão, etc)
    class ScaleManager
      def initialize(vocabulary_provider)
        @vocabulary_provider = vocabulary_provider
      end

      def scale_name(group, scale_index)
        return '' if scale_index.zero?

        scales = @vocabulary_provider.scales
        return '' if scale_index >= scales.size

        scale = scales[scale_index]
        scale.name_for_quantity(group.value)
      end
    end
  end
end
