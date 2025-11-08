# frozen_string_literal: true

module Infra
  # Classe responsável por fornecer a tabela de romanos
  class RomanTable < Domain::RomanTableProvider
    def symbols
      [
        [1000, 'M'], [900, 'CM'], [500, 'D'], [400, 'CD'],
        [100, 'C'], [90, 'XC'], [50, 'L'], [40, 'XL'],
        [10, 'X'], [9, 'IX'], [5, 'V'], [4, 'IV'], [1, 'I']
      ].freeze
    end
  end
end
