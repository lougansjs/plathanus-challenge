# frozen_string_literal: true
# rubocop:disable all

require 'io/console'
require_relative 'option1/number_to_roman'
require_relative 'option2/number_to_words'

# 🎨 Estilos ANSI
RESET   = "\e[0m"
BOLD    = "\e[1m"
CYAN    = "\e[36m"
MAGENTA = "\e[35m"
YELLOW  = "\e[33m"
GREEN   = "\e[32m"
RED     = "\e[31m"
BLUE    = "\e[34m"

def clear_screen
  system('clear') || system('cls')
end

# Menu principal interativo
def show_main_menu(selected_index = 0)
  options = [
    'Conversor de Números Romanos 🏛️',
    'Conversor de Números para Extenso 📝',
    'Sair ❌'
  ]

  puts CYAN + BOLD
  puts "╔════════════════════════════════════════════════════╗"
  puts "║          CONVERSORES DE NÚMEROS                    ║"
  puts "╚════════════════════════════════════════════════════╝" + RESET
  puts

  options.each_with_index do |option, index|
    if index == selected_index
      print GREEN + BOLD + "  ▶ " + RESET + CYAN + BOLD + option + RESET
    else
      print "    " + option
    end
    puts
  end

  puts
  puts YELLOW + "Use ↑ ↓ para navegar, ENTER para selecionar" + RESET
end

def read_key
  char = STDIN.getch
  return char if char == "\r" || char == "\n" # Enter

  if char == "\e"
    char2 = STDIN.getch
    if char2 == "["
      char3 = STDIN.getch
      case char3
      when "A" then return :up
      when "B" then return :down
      when "C" then return :right
      when "D" then return :left
      end
    end
  end

  char
end

def main_menu
  selected_index = 0

  loop do
    clear_screen
    show_main_menu(selected_index)

    key = read_key

    case key
    when :up
      selected_index = (selected_index - 1) % 3
    when :down
      selected_index = (selected_index + 1) % 3
    when "\r", "\n"
      case selected_index
      when 0
        roman_converter_interface
      when 1
        number_to_words_interface
      when 2
        return
      end
    when "q", "Q"
      return
    end
  end
end

# Interface do Conversor de Números Romanos
def roman_converter_header
  puts CYAN + BOLD
  puts "╔════════════════════════════════════════════════════╗"
  puts "║          CONVERSOR DE NÚMEROS ROMANOS 🏛️           ║"
  puts "╚════════════════════════════════════════════════════╝" + RESET
  puts
end

def roman_converter_input_prompt
  puts YELLOW + "➤ OBSERVAÇÕES:" + RESET
  puts YELLOW + "  - O número mínimo permitido é 1" + RESET
  puts YELLOW + "  - O número máximo permitido é 3.999.000" + RESET
  puts YELLOW + "  - O número deve ser um número natural (inteiro positivo)" + RESET
  puts YELLOW + "  - Valores maiores que 3.999 são convertidos com sobrelinha, porém nem todos os terminais suportam a sobrelinha" + RESET
  puts YELLOW + "  - Digite 'voltar' para retornar ao menu principal" + RESET
  print YELLOW + "\n➤ Digite um número natural: " + RESET
  gets.strip
end

def roman_converter_interface
  loop do
    clear_screen
    roman_converter_header
    input = roman_converter_input_prompt

    break if input.downcase == 'voltar' || input.downcase == 'sair'

    begin
      value = Integer(input)
      roman = NumberToRoman.to_roman(value)
      show_roman_result(value, roman)
    rescue ArgumentError => e
      show_error(e.message)
    end

    puts YELLOW + "Pressione ENTER para continuar (ou 'voltar' para sair)..." + RESET
    continue = gets.strip
    break if continue.downcase == 'voltar' || continue.downcase == 'sair'
  end
end

def show_roman_result(value, roman)
  puts
  puts MAGENTA + "↳ Resultado:" + RESET
  puts GREEN + BOLD + "   #{value} → #{roman}" + RESET
  puts
  puts CYAN + "────────────────────────────────────────────────────" + RESET
  puts
end

# Interface do Conversor de Números para Extenso
def number_to_words_header
  puts CYAN + BOLD
  puts "╔════════════════════════════════════════════════════╗"
  puts "║      CONVERSOR DE NÚMEROS PARA EXTENSO 📝          ║"
  puts "╚════════════════════════════════════════════════════╝" + RESET
  puts
end

def number_to_words_input_prompt
  puts YELLOW + "➤ OBSERVAÇÕES:" + RESET
  puts YELLOW + "  - O número mínimo permitido é 0" + RESET
  puts YELLOW + "  - O número máximo permitido é 999.999.999.999.999" + RESET
  puts YELLOW + "  - O número deve ser um número natural (inteiro não negativo)" + RESET
  puts YELLOW + "  - Digite 'voltar' para retornar ao menu principal" + RESET
  print YELLOW + "\n➤ Digite um número natural: " + RESET
  gets.strip
end

def number_to_words_interface
  loop do
    clear_screen
    number_to_words_header
    input = number_to_words_input_prompt

    break if input.downcase == 'voltar' || input.downcase == 'sair'

    begin
      value = Integer(input)
      words = NumberToWords.to_words(value)
      show_words_result(value, words)
    rescue ArgumentError => e
      show_error(e.message)
    end

    puts YELLOW + "Pressione ENTER para continuar (ou 'voltar' para sair)..." + RESET
    continue = gets.strip
    break if continue.downcase == 'voltar' || continue.downcase == 'sair'
  end
end

def show_words_result(value, words)
  puts
  puts MAGENTA + "↳ Resultado:" + RESET
  puts GREEN + BOLD + "   #{value} → #{words}" + RESET
  puts
  puts CYAN + "────────────────────────────────────────────────────" + RESET
  puts
end

def show_error(message)
  puts RED + "⚠️  Erro: #{message}" + RESET
  puts
end

# 🧠 Programa principal
begin
  main_menu
  clear_screen
  puts GREEN + BOLD + "👋 Conversor finalizado. Até a próxima!" + RESET
  puts
rescue Interrupt
  clear_screen
  puts GREEN + BOLD + "👋 Conversor finalizado. Até a próxima!" + RESET
  puts
end
