# frozen_string_literal: true
# rubocop:disable all

# Autoloader para carregar todas as dependências
module Autoloader
  def self.setup(base_path = __dir__)
    @base_path = base_path
    @loaded = {}
  end

  def self.const_missing(const_name)
    # Converte ConstantName para constant_name.rb
    file_name = const_name.to_s
                      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                      .downcase

    file_path = File.join(@base_path, "#{file_name}.rb")

    if File.exist?(file_path)
      require file_path
      @loaded[const_name] = true
      Object.const_get(const_name)
    else
      super
    end
  end

  # Carrega arquivos baseado na estrutura de diretórios
  def self.load_all
    base = @base_path || __dir__

    # Carrega em ordem de dependência
    load_domain(base)
    load_infra(base)
    load_application(base)
  end

  private

  def self.load_domain(base)
    require File.join(base, 'domain/vocabulary_provider')
    require File.join(base, 'domain/value_objects/scale')
    require File.join(base, 'domain/value_objects/number_group')
    require File.join(base, 'domain/entities/number')
    require File.join(base, 'domain/services/group_converter')
    require File.join(base, 'domain/services/scale_manager')
  end

  def self.load_infra(base)
    require File.join(base, 'infra/vocabulary/portuguese_vocabulary')
  end

  def self.load_application(base)
    require File.join(base, 'application/use_cases/convert_number_to_words')
  end
end