# frozen_string_literal: true

require_relative 'autoloader'

# Carrega todas as dependências
Autoloader.setup(__dir__)
Autoloader.load_all

# Classe responsável por converter um número para palavras em português
class NumberToWords
  def self.to_words(number)
    new.to_words(number)
  end

  def initialize
    @vocabulary_provider = Infra::Vocabulary::PortugueseVocabulary.new
    @group_converter = Domain::Services::GroupConverter.new(@vocabulary_provider)
    @scale_manager = Domain::Services::ScaleManager.new(@vocabulary_provider)
  end

  def to_words(number)
    use_case = Application::UseCases::ConvertNumberToWords.new(
      @vocabulary_provider,
      @group_converter,
      @scale_manager
    )
    use_case.call(number)
  end
end
