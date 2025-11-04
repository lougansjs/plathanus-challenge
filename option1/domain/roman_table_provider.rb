# frozen_string_literal: true

module Domain
  # Classe responsável por fornecer a tabela de romanos
  class RomanTableProvider
    def symbols
      raise NotImplementedError, 'Subclasses must implement this method'
    end
  end
end
