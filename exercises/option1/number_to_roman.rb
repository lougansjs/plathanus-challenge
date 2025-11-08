# frozen_string_literal: true

require_relative 'autoloader'
require 'debug'

# Carrega todas as dependências
Autoloader.setup(__dir__)
Autoloader.load_all

# Classe responsável por converter um número para romanos
class NumberToRoman
  def self.to_roman(number)
    new.to_roman(number)
  end

  def initialize
    @roman_converter = Domain::Services::RomanConverter.new(Infra::RomanTable.new)
    @overline_formatter = Domain::Services::OverlineFormatter.new
  end

  def to_roman(number)
    use_case = Application::UseCases::ConvertNumberToRoman.new(@roman_converter, @overline_formatter)
    use_case.call(number)
  end
end
