# Conversor de Números Romanos

Conversor de números inteiros para numerais romanos, implementado seguindo os princípios de **Domain-Driven Design (DDD)** e **Clean Architecture**.

## 📋 Funcionalidades

- Converte números inteiros (1 a 3.999.999) para numerais romanos
- Suporta números com **overline** (símbolo de sobrelinha) para valores ≥ 4000
- Validação de entrada com mensagens de erro claras

## 🚀 Uso Básico

```ruby
require_relative 'option1/number_to_roman'

# Conversão simples
NumberToRoman.to_roman(123)      # => "CXXIII"
NumberToRoman.to_roman(1999)      # => "MCMXCIX"
NumberToRoman.to_roman(4000)      # => "I̅V" (com overline)
NumberToRoman.to_roman(1234567)   # => "M̅C̅C̅X̅X̅X̅I̅V̅DLXVII"
```

## 📁 Estrutura do Projeto

O projeto segue uma arquitetura em camadas:

```
option1/
├── number_to_roman.rb              # Ponto de entrada
├── autoloader.rb                   # Carregador de dependências
├── test_case.rb                    # Suite de testes
├── domain/                         # Camada de Domínio
│   ├── entities/
│   │   └── number.rb              # Entidade Number (validação)
│   ├── services/
│   │   ├── roman_converter.rb     # Conversão básica (1-3999)
│   │   └── overline_formatter.rb  # Formatação com overline
│   └── roman_table_provider.rb    # Interface para tabela de símbolos
├── application/                    # Camada de Aplicação
│   └── use_cases/
│       └── convert_number_to_roman.rb  # Orquestração da conversão
└── infra/                         # Camada de Infraestrutura
    └── roman_table.rb             # Implementação da tabela de símbolos
```

## 🏗️ Arquitetura

### Camada de Domínio (`domain/`)
- **Entities**: Representam entidades de negócio com regras de validação
- **Services**: Contêm lógica de negócio específica (conversão, formatação)
- **Providers**: Interfaces que definem contratos (ex: `RomanTableProvider`)

### Camada de Aplicação (`application/`)
- **Use Cases**: Orquestram a lógica de negócio, coordenando serviços e entidades

### Camada de Infraestrutura (`infra/`)
- Implementações concretas de interfaces do domínio (ex: `RomanTable`)

## 🔄 Fluxo de Execução

1. **Entrada**: `NumberToRoman.to_roman(number)`
2. **Validação**: `Domain::Entities::Number` valida o número (1 ≤ n ≤ 3.999.999)
3. **Conversão**: 
   - Números < 4000: `RomanConverter` converte diretamente
   - Números ≥ 4000: Divide em parte maior e menor, aplica overline na maior
4. **Formatação**: `OverlineFormatter` adiciona sobrelinha quando necessário
5. **Saída**: String com numeral romano

## 📊 Limites e Regras

- **Mínimo**: 1 (números naturais positivos)
- **Máximo**: 3.999.999
- **Overline**: Aplicado automaticamente para números ≥ 4000
- **Validação**: Rejeita zero, negativos, floats e tipos inválidos

## 🔧 Dependências

- **Ruby 3.1.7+** (compatível com versões anteriores)
- Nenhuma gem externa necessária (apenas biblioteca padrão)

## 💡 Exemplos

```ruby
# Casos básicos
NumberToRoman.to_roman(1)        # => "I"
NumberToRoman.to_roman(4)        # => "IV"
NumberToRoman.to_roman(9)        # => "IX"

# Números compostos
NumberToRoman.to_roman(1999)     # => "MCMXCIX"
NumberToRoman.to_roman(2345)     # => "MMCCCXLV"

# Números com overline
NumberToRoman.to_roman(4000)     # => "I̅V"
NumberToRoman.to_roman(10000)    # => "X̅"
NumberToRoman.to_roman(1234567)  # => "M̅C̅C̅X̅X̅X̅I̅V̅DLXVII"

# Tratamento de erros
NumberToRoman.to_roman(0)        # => ArgumentError
NumberToRoman.to_roman(-1)       # => ArgumentError
NumberToRoman.to_roman(4000000)  # => ArgumentError
```

## 📝 Notas Técnicas

- **Autoloader**: Carrega automaticamente todas as dependências na ordem correta
- **Frozen Strings**: Utiliza `frozen_string_literal: true` para otimização
- **Imutabilidade**: Entidades e Value Objects são imutáveis quando possível
- **Separação de Responsabilidades**: Cada classe tem uma única responsabilidade bem definida