# Backend Plathanus Real Estate

API RESTful desenvolvida em Ruby on Rails para gerenciamento de imóveis, seguindo os princípios de Domain-Driven Design (DDD) e Clean Architecture.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias](#tecnologias)
- [Arquitetura](#arquitetura)
- [Requerimentos](#requerimentos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Como Iniciar](#como-iniciar)
- [Testes](#testes)
- [Documentação da API](#documentação-da-api)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Padrões e Convenções](#padrões-e-convenções)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Deploy](#deploy)
- [Contribuindo](#contribuindo)

## 🎯 Sobre o Projeto

Este projeto é uma API RESTful para gerenciamento de imóveis, permitindo operações CRUD completas, autenticação de administradores, upload de fotos e filtros avançados de busca. A aplicação foi desenvolvida seguindo os princípios de Domain-Driven Design (DDD) e Clean Architecture, garantindo separação de responsabilidades e alta testabilidade.

### Funcionalidades Principais

- ✅ Autenticação de administradores com JWT
- ✅ CRUD completo de imóveis
- ✅ Upload e gerenciamento de fotos de imóveis
- ✅ Sistema de categorias
- ✅ Filtros avançados de busca (preço, localização, tipo de contrato, etc.)
- ✅ Paginação de resultados
- ✅ Cache de respostas
- ✅ Documentação Swagger/OpenAPI
- ✅ Testes automatizados com RSpec

## 🛠 Tecnologias

### Core
- **Ruby** 3.4.4
- **Rails** 8.0.2 (API-only mode)
- **PostgreSQL** 16
- **Puma** (servidor web)

### Autenticação e Segurança
- **JWT** (JSON Web Tokens)
- **BCrypt** (hash de senhas)
- **Rack::Attack** (proteção contra ataques)

### Armazenamento
- **Active Storage** (gerenciamento de arquivos)
- **MinIO** (S3-compatible object storage)
- **AWS SDK S3** (cliente S3)

### Testes
- **RSpec** (framework de testes)
- **Factory Bot** (factories para testes)
- **Shoulda Matchers** (matchers para testes)
- **Database Cleaner** (limpeza de banco entre testes)
- **SimpleCov** (cobertura de código)

### Documentação
- **Rswag** (Swagger/OpenAPI para Rails)

## 🏗 Arquitetura

O projeto segue os princípios de **Domain-Driven Design (DDD)** e **Clean Architecture**, organizando o código em camadas bem definidas:

```
app/
├── domain/          # Camada de Domínio (regras de negócio)
│   ├── entities/    # Entidades de domínio
│   ├── repositories/ # Interfaces de repositórios
│   ├── services/     # Serviços de domínio
│   └── value_objects/ # Objetos de valor
│
├── application/     # Camada de Aplicação (casos de uso)
│   ├── use_cases/    # Casos de uso da aplicação
│   └── dto/          # Data Transfer Objects
│
├── infrastructure/  # Camada de Infraestrutura (implementações)
│   ├── persistence/  # Implementações de repositórios (ActiveRecord)
│   ├── mappers/      # Mapeadores entre camadas
│   └── services/     # Serviços de infraestrutura
│
└── controllers/     # Camada de Apresentação (API)
    └── api/v1/       # Controllers da API v1
```

### Princípios da Arquitetura

- **Separação de Responsabilidades**: Cada camada tem uma responsabilidade específica
- **Inversão de Dependências**: Camadas superiores não dependem de camadas inferiores
- **Testabilidade**: Fácil de testar isoladamente cada componente
- **Manutenibilidade**: Código organizado e fácil de manter

## 📦 Requerimentos

### Desenvolvimento Local

- **Ruby** 3.4.4
- **PostgreSQL** 16
- **Bundler** (gerenciador de gems)
- **Node.js** (opcional, para algumas ferramentas)

### Docker (Recomendado)

- **Docker** 20.10+
- **Docker Compose** 2.0+

## 🚀 Instalação

### Opção 1: Com Docker (Recomendado)

1. Clone o repositório:
```bash
git clone <repository-url>
cd backend-plathanus-real-estate
```

2. Inicie os serviços com Docker Compose:
```bash
docker-compose up -d
```

Isso irá:
- Criar e iniciar o container do PostgreSQL
- Criar e iniciar o container do MinIO
- Construir e iniciar o container da aplicação Rails
- Executar as migrations automaticamente

3. Acesse a aplicação:
- API: http://localhost:3001
- Swagger UI: http://localhost:3001/api-docs
- MinIO Console: http://localhost:9001

### Opção 2: Desenvolvimento Local (Sem Docker)

1. Instale as dependências do sistema:
```bash
# Ubuntu/Debian
sudo apt-get install postgresql-16 libpq-dev build-essential libvips
```

2. Instale o Ruby 3.4.4 (recomendado usar mise, rbenv ou rvm):
```bash
rbenv install 3.4.4
rbenv local 3.4.4
```

3. Instale as gems:
```bash
bundle install
```

4. Configure o banco de dados:
```bash
# Crie o banco de dados
rails db:create

# Execute as migrations
rails db:migrate

# (Opcional) Popule o banco com dados de exemplo
rails db:seed
```

5. Configure o MinIO ou use storage local:
   - Para desenvolvimento, você pode usar o storage local configurado em `config/storage.yml`
   - Ou inicie um container MinIO separadamente

6. Inicie o servidor:
```bash
rails server
```

## ⚙️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto (ou use as variáveis do `docker-compose.yml`):

```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=plathanus_real_estate_development

# MinIO/S3
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY_ID=minioadmin
MINIO_SECRET_ACCESS_KEY=minioadmin
MINIO_REGION=us-east-1
MINIO_BUCKET=plathanus-real-estate-development
ACTIVE_STORAGE_SERVICE=minio

# CORS
RAILS_CORS_ORIGINS=http://localhost:3001,http://127.0.0.1:3001

# Rails
RAILS_ENV=development
PORT=3001
```

### Configuração do MinIO

1. Acesse o console do MinIO: http://localhost:9001
2. Login: `minioadmin` / `minioadmin`
3. Crie um bucket com o nome especificado em `MINIO_BUCKET`
4. Configure as políticas de acesso conforme necessário

## 🏃 Como Iniciar

### Com Docker

```bash
# Iniciar todos os serviços
docker-compose up

# Iniciar em background
docker-compose up -d

# Ver logs
docker-compose logs -f web

# Parar os serviços
docker-compose down

# Parar e remover volumes
docker-compose down -v
```

### Sem Docker

```bash
# Iniciar o servidor Rails
rails server

# Ou em uma porta específica
rails server -p 3001
```

## 🧪 Testes

O projeto utiliza **RSpec** como framework de testes, com cobertura de código via **SimpleCov**.

### Executando os Testes

```bash
# Todos os testes
bundle exec rspec

# Testes específicos
bundle exec rspec spec/controllers/api/v1/properties_controller_spec.rb

# Com cobertura de código
COVERAGE=true bundle exec rspec

# Ver relatório de cobertura
open coverage/index.html
```

### Estrutura de Testes

Os testes seguem a mesma estrutura da aplicação:

```
spec/
├── domain/              # Testes de entidades, value objects, serviços de domínio
├── application/         # Testes de casos de uso
├── controllers/         # Testes de controllers (request specs)
└── support/             # Helpers e configurações de teste
```


## 📚 Documentação da API

A documentação da API está disponível via **Swagger/OpenAPI**:

- **Swagger UI**: http://localhost:3001/api-docs

### Endpoints Principais

#### Autenticação
- `POST /api/v1/auth/login` - Login de administrador
- `GET /api/v1/auth/verify` - Verificar token JWT

#### Imóveis
- `GET /api/v1/properties` - Listar imóveis (com filtros e paginação)
- `GET /api/v1/properties/:id` - Detalhes de um imóvel
- `POST /api/v1/properties` - Criar imóvel
- `PUT /api/v1/properties/:id` - Atualizar imóvel
- `DELETE /api/v1/properties/:id` - Deletar imóvel
- `DELETE /api/v1/properties/:id/delete_photo` - Deletar foto de imóvel

#### Categorias
- `GET /api/v1/categories` - Listar categorias

### Autenticação

A API utiliza **JWT (JSON Web Tokens)** para autenticação. Para acessar endpoints protegidos:

1. Faça login em `POST /api/v1/auth/login`
2. Receba o token JWT na resposta
3. Inclua o token no header: `Authorization: Bearer <token>`

## 📁 Estrutura do Projeto

```
backend-plathanus-real-estate/
├── app/
│   ├── application/          # Casos de uso e DTOs
│   ├── controllers/           # Controllers da API
│   ├── domain/                # Entidades, repositórios, serviços de domínio
│   ├── infrastructure/        # Implementações (ActiveRecord, mappers)
│   ├── jobs/                  # Background jobs
│   ├── models/                # Models ActiveRecord (legacy)
│   ├── serializers/           # Serializers JSON
│   └── services/              # Serviços auxiliares
│
├── config/                    # Configurações do Rails
│   ├── initializers/          # Inicializadores
│   └── environments/          # Configurações por ambiente
│
├── db/
│   ├── migrate/               # Migrations
│   └── seeds.rb               # Seeds
│
├── spec/                      # Testes RSpec
│   ├── domain/
│   ├── application/
│   ├── controllers/
│   └── support/
│
├── swagger/                   # Documentação Swagger
│   └── v1/
│       └── swagger.yaml
│
├── docker-compose.yml         # Configuração Docker Compose
├── Dockerfile                 # Dockerfile da aplicação
├── Gemfile                    # Dependências Ruby
└── README.md                  # Este arquivo
```

## 📐 Padrões e Convenções

### Padrões de Código

- **RuboCop**: Linter configurado com `rubocop-rails-omakase`
- **Convenções Rails**: Segue as convenções padrão do Rails
- **DDD**: Organização por domínios (properties, categories, authentication)

### Nomenclatura

- **Entidades**: Classes de domínio (ex: `Property`, `Category`)
- **Repositórios**: Interfaces em `domain/*/repositories/`, implementações em `infrastructure/persistence/`
- **Use Cases**: Classes em `application/*/use_cases/` (ex: `CreateProperty`)
- **DTOs**: Classes em `application/*/dto/` (ex: `PropertyCreateDto`)
- **Value Objects**: Classes em `domain/*/value_objects/` (ex: `Price`, `Coordinates`)

### Convenções de Commits

Seguir padrão de commits semânticos:
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `test:` Testes
- `refactor:` Refatoração
- `style:` Formatação
- `chore:` Manutenção

## 🔐 Variáveis de Ambiente

### Desenvolvimento

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `DATABASE_HOST` | Host do PostgreSQL | `localhost` |
| `DATABASE_PORT` | Porta do PostgreSQL | `5432` |
| `DATABASE_USERNAME` | Usuário do PostgreSQL | `postgres` |
| `DATABASE_PASSWORD` | Senha do PostgreSQL | `postgres` |
| `DATABASE_NAME` | Nome do banco de dados | `plathanus_real_estate_development` |
| `MINIO_ENDPOINT` | Endpoint do MinIO | `http://localhost:9000` |
| `MINIO_ACCESS_KEY_ID` | Access Key do MinIO | `minioadmin` |
| `MINIO_SECRET_ACCESS_KEY` | Secret Key do MinIO | `minioadmin` |
| `MINIO_REGION` | Região do MinIO | `us-east-1` |
| `MINIO_BUCKET` | Nome do bucket | `plathanus-real-estate-development` |
| `RAILS_CORS_ORIGINS` | Origens permitidas para CORS | `http://localhost:3001` |
| `RAILS_ENV` | Ambiente Rails | `development` |
| `PORT` | Porta da aplicação | `3001` |


## 📝 Licença

Este projeto faz parte do desafio Plathanus.

## 👥 Autores

- Desenvolvido como parte do desafio técnico Plathanus

---

**Desenvolvido com ❤️ usando Ruby on Rails & Café**
