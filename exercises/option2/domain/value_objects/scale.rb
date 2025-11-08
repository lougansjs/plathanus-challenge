# frozen_string_literal: true

module Domain
  module ValueObjects
    # Classe responsável por representar uma escala
    class Scale
      attr_reader :singular, :plural, :index

      def initialize(singular:, plural:, index:)
        @singular = singular
        @plural = plural
        @index = index
      end

      def name_for_quantity(quantity)
        quantity > 1 ? @plural : @singular
      end
    end
  end
end
