# frozen_string_literal: true

module Domain
  module Services
    # Classe responsável por formatar um número com sobrelinha
    class OverlineFormatter
      OVERLINE = "\u0305"

      def format(roman)
        roman.chars.map { |c| "#{c}#{OVERLINE}" }.join
      end
    end
  end
end
