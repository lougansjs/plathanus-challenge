# Conversor de Números para Palavras

Conversor de números inteiros para palavras em português, implementado seguindo os princípios de **Domain-Driven Design (DDD)** e **Clean Architecture**.

## 📋 Funcionalidades

- Converte números inteiros (0 a 999.999.999.999.999) para palavras em português
- Suporta múltiplas escalas (mil, milhão, bilhão e trilhão)
- Formatação gramatical correta com conectivos adequados
- Validação de entrada com mensagens de erro claras
- Suporte para zero e números negativos (apenas números naturais ≥ 0)

## 🚀 Uso Básico

```ruby
require_relative 'option2/number_to_words'

# Conversão simples
NumberToWords.to_words(0)          # => "zero"
NumberToWords.to_words(123)        # => "cento e vinte e três"
NumberToWords.to_words(1000)       # => "mil"
NumberToWords.to_words(1999)       # => "mil novecentos e noventa e nove"

# Números grandes
NumberToWords.to_words(1000000)    # => "um milhão"
NumberToWords.to_words(1234567)    # => "um milhão duzentos e trinta e quatro mil quinhentos e sessenta e sete"
```

## 📁 Estrutura do Projeto

O projeto segue uma arquitetura em camadas:

```
option2/
├── number_to_words.rb              # Ponto de entrada
├── autoloader.rb                   # Carregador de dependências
├── domain/                         # Camada de Domínio
│   ├── entities/
│   │   └── number.rb               # Entidade Number (validação e divisão em grupos)
│   ├── services/
│   │   ├── group_converter.rb      # Conversão de grupos de 3 dígitos
│   │   └── scale_manager.rb        # Gerenciamento de escalas (mil, milhão, etc)
│   ├── value_objects/
│   │   ├── number_group.rb         # Value Object para grupo de 3 dígitos
│   │   └── scale.rb                # Value Object para escala numérica
│   └── vocabulary_provider.rb      # Interface para vocabulário
├── application/                    # Camada de Aplicação
│   └── use_cases/
│       └── convert_number_to_words.rb  # Orquestração da conversão
└── infra/                         # Camada de Infraestrutura
    └── vocabulary/
        └── portuguese_vocabulary.rb    # Implementação do vocabulário em português
```

## 🏗️ Arquitetura

### Camada de Domínio (`domain/`)

- **Entities**: Representam entidades de negócio com regras de validação
  - `Number`: Valida e divide números em grupos de 3 dígitos
- **Services**: Contêm lógica de negócio específica
  - `GroupConverter`: Converte grupos de 3 dígitos (0-999) em palavras
  - `ScaleManager`: Gerencia escalas (mil, milhão, bilhão, etc) e suas variações
- **Value Objects**: Objetos imutáveis que representam conceitos do domínio
  - `NumberGroup`: Representa um grupo de até 3 dígitos (0-999)
  - `Scale`: Representa uma escala numérica com suas regras gramaticais
- **Providers**: Interfaces que definem contratos
  - `VocabularyProvider`: Interface para diferentes implementações de vocabulário

### Camada de Aplicação (`application/`)

- **Use Cases**: Orquestram a lógica de negócio, coordenando serviços e entidades
  - `ConvertNumberToWords`: Coordena a conversão de número completo em palavras

### Camada de Infraestrutura (`infra/`)

- Implementações concretas de interfaces do domínio
  - `PortugueseVocabulary`: Implementação do vocabulário em português brasileiro

## 🔄 Fluxo de Execução

1. **Entrada**: `NumberToWords.to_words(number)`
2. **Validação**: `Option2::Domain::Entities::Number` valida o número (0 ≤ n < 1.000.000.000.000.000)
3. **Divisão em Grupos**: O número é dividido em grupos de 3 dígitos (da direita para esquerda)
4. **Conversão de Grupos**: Cada grupo é convertido em palavras usando `GroupConverter`
5. **Aplicação de Escalas**: `ScaleManager` aplica as escalas apropriadas (mil, milhão, etc)
6. **Junção**: Os grupos são unidos com conectivos gramaticais corretos ("e", ",", etc)
7. **Saída**: String com número por extenso em português

## 📊 Limites e Regras

- **Mínimo**: 0 (zero)
- **Máximo**: 999.999.999.999.999 (999 quatrilhões)
- **Validação**: Rejeita negativos, floats e tipos inválidos
- **Regras Gramaticais**:
  - "Mil" não leva "um" quando é exatamente 1000
  - Conectivos "e" são usados entre dezenas e unidades
  - Vírgulas são usadas entre escalas maiores
  - "E" final conecta a última escala ao grupo menor

## 🔧 Dependências

- **Ruby 3.1.7+** (compatível com versões anteriores)
- Nenhuma gem externa necessária (apenas biblioteca padrão)

## 💡 Exemplos

```ruby
# Casos básicos
NumberToWords.to_words(0)          # => "zero"
NumberToWords.to_words(1)          # => "um"
NumberToWords.to_words(10)         # => "dez"
NumberToWords.to_words(21)         # => "vinte e um"

# Centenas
NumberToWords.to_words(100)        # => "cem"
NumberToWords.to_words(101)        # => "cento e um"
NumberToWords.to_words(999)        # => "novecentos e noventa e nove"

# Milhares
NumberToWords.to_words(1000)       # => "mil"
NumberToWords.to_words(1001)       # => "mil e um"
NumberToWords.to_words(1234)       # => "mil duzentos e trinta e quatro"
NumberToWords.to_words(9999)       # => "nove mil novecentos e noventa e nove"

# Milhões
NumberToWords.to_words(1000000)    # => "um milhão"
NumberToWords.to_words(1000001)   # => "um milhão e um"
NumberToWords.to_words(1234567)   # => "um milhão duzentos e trinta e quatro mil quinhentos e sessenta e sete"

# Bilhões
NumberToWords.to_words(1000000000) # => "um bilhão"
NumberToWords.to_words(1234567890) # => "um bilhão duzentos e trinta e quatro milhões quinhentos e sessenta e sete mil oitocentos e noventa"

# Tratamento de erros
NumberToWords.to_words(-1)         # => ArgumentError
NumberToWords.to_words(1.5)       # => ArgumentError
NumberToWords.to_words("123")     # => ArgumentError
NumberToWords.to_words(1000000000000000) # => ArgumentError
```

## 📝 Notas Técnicas

- **Autoloader**: Carrega automaticamente todas as dependências na ordem correta
- **Frozen Strings**: Utiliza `frozen_string_literal: true` para otimização
- **Imutabilidade**: Entidades e Value Objects são imutáveis
- **Separação de Responsabilidades**: Cada classe tem uma única responsabilidade bem definida
- **Value Objects**: Uso de Value Objects para representar conceitos do domínio (NumberGroup, Scale)
- **Extensibilidade**: Interface `VocabularyProvider` permite adicionar novos idiomas facilmente

## 🔍 Regras Gramaticais Implementadas

- **Zero**: Representado como "zero"
- **Unidades (1-9)**: "um", "dois", "três", etc
- **Dezenas Especiais (10-19)**: "dez", "onze", "doze", etc
- **Dezenas (20-99)**: "vinte", "trinta", com conectivo "e" para unidades
- **Centenas (100-999)**: "cem", "cento", "duzentos", etc
- **Mil (1000)**: "mil" sem "um" quando é exatamente 1000
- **Escalas**: Pluralização correta (mil/mil, milhão/milhões, etc)

## 🌐 Extensibilidade

O sistema foi projetado para ser facilmente extensível:

- **Novos Idiomas**: Implemente `VocabularyProvider` com vocabulário específico
- **Novas Escalas**: Adicione escalas ao `PortugueseVocabulary`
- **Novas Regras**: Estenda `ScaleManager` ou `GroupConverter` para novas regras gramaticais
