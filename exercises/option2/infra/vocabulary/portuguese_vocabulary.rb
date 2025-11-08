# frozen_string_literal: true

module Infra
  module Vocabulary
    # Classe responsável por fornecer o vocabulário em português
    class PortugueseVocabulary < Domain::VocabularyProvider
      def units
        %w[zero um dois três quatro cinco seis sete oito nove].freeze
      end

      def special_tens
        %w[dez onze doze treze quatorze quinze dezesseis dezessete dezoito dezenove].freeze
      end

      def tens
        %w[vinte trinta quarenta cinquenta sessenta setenta oitenta noventa]
          .prepend('', '')
          .freeze
      end

      def hundreds
        %w[cento duzentos trezentos quatrocentos quinhentos seiscentos setecentos oitocentos novecentos]
          .prepend('')
          .freeze
      end

      def scales
        [
          Domain::ValueObjects::Scale.new(singular: '', plural: '', index: 0),
          Domain::ValueObjects::Scale.new(singular: 'mil', plural: 'mil', index: 1),
          Domain::ValueObjects::Scale.new(singular: 'milhão', plural: 'milhões', index: 2),
          Domain::ValueObjects::Scale.new(singular: 'bilhão', plural: 'bilhões', index: 3),
          Domain::ValueObjects::Scale.new(singular: 'trilhão', plural: 'trilhões', index: 4)
        ]
      end
    end
  end
end
