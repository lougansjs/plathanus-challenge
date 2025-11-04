# Plathanus - Conversores de Números

Projeto de estudo que implementa dois conversores de números utilizando **Domain-Driven Design (DDD)** e **Clean Architecture**:

- **Conversor de Números Romanos** (option1): Converte números inteiros para numerais romanos
- **Conversor de Números para Palavras** (option2): Converte números inteiros para palavras em português

## 📋 Funcionalidades

### Interface Interativa 🎮
- Menu interativo via terminal para escolher entre os conversores
- Navegação com setas do teclado
- Interface colorida e amigável

## 🚀 Como Usar

### Executar Interface Interativa

```bash
ruby main.rb
```

A interface interativa permite escolher entre os dois conversores e testar conversões de forma interativa.

## 🐳 Executar com Docker

### Usando Docker Compose

```bash
docker compose build --no-cache
docker compose run --rm plathanus
```

### Usando Docker diretamente

```bash
docker build -t plathanus .
docker run -it plathanus
```

## 🔧 Requisitos

- **Ruby 3.1.7+** (compatível com versões anteriores)
- **Docker**: 28.3.2
- **Docker Compose**: v2.32.1
- Nenhuma gem externa necessária (apenas biblioteca padrão)
- Para interface interativa: terminal com suporte a ANSI colors e teclas de seta

### Usando Mise (recomendado)

Se você usa [mise](https://mise.jdx.dev/), a versão do Ruby será configurada automaticamente:

```bash
mise install
```

## 📚 Documentação Detalhada

Para mais informações sobre cada módulo, consulte:

- [Documentação do Conversor de Números Romanos](option1/readme.md)
- [Documentação do Conversor de Números para Palavras](option2/readme.md)

## 🎯 Objetivos do Projeto

Este projeto foi desenvolvido como um estudo de:

- **Domain-Driven Design (DDD)**: Separação clara entre domínio, aplicação e infraestrutura
- **Clean Architecture**: Arquitetura em camadas com dependências bem definidas
- **Extensibilidade**: Interfaces que permitem extensões futuras
- **Imutabilidade**: Uso de objetos imutáveis quando possível
- **Separação de Responsabilidades**: Cada classe com uma única responsabilidade

## 🔄 Próximos Passos

Possíveis melhorias futuras:

- [ ] Adicionar suporte para mais idiomas no conversor de palavras
- [ ] Adicionar testes automatizados com RSpec ou Minitest
- [ ] Adicionar suporte para números decimais
- [ ] Melhorar a interface interativa com mais opções
- [ ] Adicionar histórico de conversões
- [ ] Criar uma API REST para os conversores

## 📄 Licença

Este projeto é um projeto de estudo e não possui licença específica.

---

**Desenvolvido como projeto de estudo em Ruby** 🚀
