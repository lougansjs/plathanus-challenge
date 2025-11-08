# frozen_string_literal: true

module Domain
  # Classe responsável por fornecer o vocabulário
  class VocabularyProvider
    def units
      raise NotImplementedError, 'Subclasses must implement this method'
    end

    def special_tens
      raise NotImplementedError, 'Subclasses must implement this method'
    end

    def tens
      raise NotImplementedError, 'Subclasses must implement this method'
    end

    def hundreds
      raise NotImplementedError, 'Subclasses must implement this method'
    end

    def scales
      raise NotImplementedError, 'Subclasses must implement this method'
    end
  end
end
