# 🏠 Frontend Plathanus Real Estate

Frontend da aplicação de imóveis desenvolvido com **Nuxt 3** para o desafio da Plathanus. Aplicação SPA (Single Page Application) com gerenciamento de estado, autenticação, integração com Google Maps e interface administrativa.

> **💡 Nota:** Este frontend pode conter algumas coisas erradas, pois o **Nuxt.js** é uma tecnologia que estou estudando e não conheço tanto quanto o frontend padrão do Rails (Hotwire). Esta é uma tentativa de inovar e aprender algo novo durante o desenvolvimento e devo dizer: é incrível! 🚀

## 📋 Índice

- [Tecnologias](#-tecnologias)
- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Configuração](#-configuração)
- [Como Executar](#-como-executar)
- [Docker](#-docker)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Padrões e Convenções](#-padrões-e-convenções)
- [Variáveis de Ambiente](#-variáveis-de-ambiente)
- [Scripts Disponíveis](#-scripts-disponíveis)
- [Funcionalidades](#-funcionalidades)
- [Contribuindo](#-contribuindo)

## 🛠 Tecnologias

### Core
- **[Nuxt 3](https://nuxt.com/)** (v4.2.0) - Framework Vue.js com SSR desabilitado (SPA mode)
- **[Vue 3](https://vuejs.org/)** (v3.5.22) - Framework JavaScript reativo
- **[TypeScript](https://www.typescriptlang.org/)** - Tipagem estática
- **[Pinia](https://pinia.vuejs.org/)** (v3.0.4) - Gerenciamento de estado

### Estilização
- **[Tailwind CSS](https://tailwindcss.com/)** (v3.4.17) - Framework CSS utility-first
- **[Lucide Vue Next](https://lucide.dev/)** (v0.552.0) - Biblioteca de ícones

### Integrações
- **[Axios](https://axios-http.com/)** (v1.13.2) - Cliente HTTP
- **[Google Maps JavaScript API](https://developers.google.com/maps/documentation/javascript)** - Integração com mapas

### Ferramentas de Desenvolvimento
- **Yarn** - Gerenciador de pacotes
- **Docker** - Containerização

## 📦 Requisitos

Antes de começar, certifique-se de ter instalado:

- **Node.js** >= 18.x
- **Yarn** >= 1.22.x (ou npm)
- **Docker** e **Docker Compose** (opcional, para desenvolvimento com containers)

## 🚀 Instalação

### 1. Clone o repositório

```bash
git clone <url-do-repositório>
cd frontend-plathanus-real-state
```

### 2. Instale as dependências

```bash
yarn install
# ou
npm install
```

### 3. Configure as variáveis de ambiente

Copie o arquivo de exemplo e configure as variáveis:

```bash
cp env.example .env
```

Edite o arquivo `.env` com suas configurações (veja [Variáveis de Ambiente](#-variáveis-de-ambiente)).

## ⚙️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto baseado no `env.example`:

```env
# URL base da API backend
NUXT_PUBLIC_API_BASE_URL=http://0.0.0.0:3001/api/v1

# Chave da API do Google Maps
NUXT_PUBLIC_GOOGLE_MAPS_API_KEY=sua-chave-aqui
```

**Nota:** Como o Nuxt está configurado com SSR desabilitado, as requisições são feitas diretamente do navegador. Portanto, use `localhost:3001` ou `0.0.0.0:3001` para acessar o backend.

### Obter Chave do Google Maps

1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Ative a **Maps JavaScript API**
4. Crie uma chave de API em "Credenciais"
5. Adicione a chave no arquivo `.env`

**Nota:** Amigavelmente, já deixei uma API Key do GCP configurada e que irá expirar em 5 dias.

## 🏃 Como Executar

### Desenvolvimento Local

```bash
# Iniciar servidor de desenvolvimento
yarn dev
# ou
npm run dev
```

A aplicação estará disponível em `http://localhost:3000`


## 🐳 Docker

### Desenvolvimento com Docker Compose

O projeto inclui configuração Docker para facilitar o desenvolvimento:

```bash
# Iniciar container
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar container
docker-compose down
```

O container irá:
- Instalar dependências automaticamente
- Montar o código fonte para hot-reload
- Expor a aplicação na porta `3000`
- Usar a rede `plathanus-network` para comunicação com outros serviços

### Dockerfile

O Dockerfile está configurado para desenvolvimento com:
- Node.js 20 Alpine
- Yarn como gerenciador de pacotes
- Hot-reload habilitado
- Porta 3000 exposta

## 📁 Estrutura do Projeto

```
frontend-plathanus-real-state/
├── app/                      # Diretório principal da aplicação
│   ├── components/          # Componentes Vue reutilizáveis
│   │   ├── auth/            # Componentes de autenticação
│   │   ├── layouts/         # Componentes de layout
│   │   ├── properties/      # Componentes relacionados a imóveis
│   │   └── ui/              # Componentes de UI genéricos
│   ├── composables/         # Composables Vue (lógica reutilizável)
│   ├── layouts/             # Layouts da aplicação
│   │   ├── admin.vue        # Layout para área administrativa
│   │   └── default.vue      # Layout padrão
│   ├── pages/               # Páginas (roteamento automático)
│   │   ├── admin/           # Páginas administrativas
│   │   ├── properties/      # Páginas de imóveis
│   │   ├── imoveis.vue      # Listagem de imóveis
│   │   └── index.vue        # Página inicial
│   ├── plugins/             # Plugins Nuxt
│   │   └── api.ts           # Configuração do Axios
│   ├── services/            # Serviços (HTTP, error handling)
│   ├── stores/              # Stores Pinia
│   │   ├── auth.ts          # Store de autenticação
│   │   ├── categories.ts    # Store de categorias
│   │   └── properties.ts    # Store de imóveis
│   └── app.vue              # Componente raiz
├── assets/                  # Assets estáticos (CSS, imagens)
├── types/                   # Definições TypeScript
│   ├── api.ts              # Tipos da API
│   ├── category.ts         # Tipos de categorias
│   ├── property.ts         # Tipos de imóveis
│   └── google-maps.d.ts    # Tipos do Google Maps
├── public/                  # Arquivos públicos estáticos
├── .nuxt/                   # Build do Nuxt (gerado)
├── nuxt.config.ts          # Configuração do Nuxt
├── tailwind.config.cjs      # Configuração do Tailwind
├── tsconfig.json            # Configuração do TypeScript
├── Dockerfile               # Dockerfile para containerização
├── docker-compose.yml       # Configuração Docker Compose
├── entrypoint.sh            # Script de entrada do Docker
├── package.json             # Dependências e scripts
└── README.md                # Este arquivo
```

## 📐 Padrões e Convenções

### Estrutura de Componentes

- **Componentes** seguem a convenção PascalCase
- Componentes são auto-importados pelo Nuxt (não é necessário importar manualmente)
- Componentes específicos de domínio ficam em pastas dedicadas (ex: `components/properties/`)
- Componentes genéricos de UI ficam em `components/ui/`

### Gerenciamento de Estado

- **Pinia** é usado para gerenciamento de estado global
- Stores ficam em `app/stores/`
- Cada store representa um domínio específico (auth, properties, categories)

### Composables

- Lógica reutilizável é encapsulada em composables
- Composables ficam em `app/composables/`
- Exemplos: `useGoogleMaps`, `useMoney`, `usePropertyStatus`

### Roteamento

Reamente é possivél amar Nuxt.js

- Nuxt usa **file-based routing**
- Páginas em `app/pages/` são automaticamente convertidas em rotas
- Rotas dinâmicas usam colchetes: `[id].vue` → `/properties/:id`

### Estilização

- **Tailwind CSS** para estilização
- Classes utilitárias do Tailwind são preferidas
- CSS customizado em `assets/css/tailwind.css`

### TypeScript

- Todo o código é tipado com TypeScript
- Tipos compartilhados ficam em `types/`
- Interfaces seguem convenção PascalCase

### Requisições HTTP

- **Axios** é configurado via plugin em `app/plugins/api.ts`
- Token JWT é automaticamente adicionado via interceptor
- Tratamento de erros 401 (não autorizado) é automático

## 🔐 Variáveis de Ambiente

| Variável | Descrição | Obrigatória | Padrão |
|----------|-----------|-------------|--------|
| `NUXT_PUBLIC_API_BASE_URL` | URL base da API backend | Sim | `http://0.0.0.0:3001/api/v1` |
| `NUXT_PUBLIC_GOOGLE_MAPS_API_KEY` | Chave da API do Google Maps | Sim | - |

**Importante:** Variáveis que começam com `NUXT_PUBLIC_` são expostas ao cliente (navegador).

## ✨ Funcionalidades

### Área Pública
- ✅ Listagem de imóveis com filtros
- ✅ Visualização detalhada de imóveis
- ✅ Galeria de fotos
- ✅ Mapa interativo com Google Maps
- ✅ Busca e filtros avançados
- ✅ Design responsivo

### Área Administrativa
- ✅ Autenticação com JWT
- ✅ Dashboard administrativo
- ✅ CRUD completo de imóveis
- ✅ Upload de fotos
- ✅ Gerenciamento de categorias
- ✅ Edição de propriedades

### Recursos Técnicos
- ✅ SPA (Single Page Application)
- ✅ Gerenciamento de estado com Pinia
- ✅ Autenticação persistente
- ✅ Interceptores HTTP para tokens
- ✅ Tratamento de erros
- ✅ TypeScript em todo o projeto
- ✅ Componentes reutilizáveis


### Padrões de Commit

Seguir o padrão [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adiciona nova funcionalidade
fix: corrige bug
docs: atualiza documentação
style: formatação de código
refactor: refatoração de código
test: adiciona testes
chore: tarefas de manutenção
```

## 📝 Notas Importantes

- O projeto está configurado com **SSR desabilitado** (`ssr: false`), funcionando como SPA
- O diretório fonte está em `app/` (configurado via `srcDir: 'app'`)
- O servidor de desenvolvimento aceita conexões de qualquer IP (`host: '0.0.0.0'`)
- Hot Module Replacement (HMR) está configurado para desenvolvimento
- O projeto usa Yarn como gerenciador de pacotes padrão

## 🐛 Troubleshooting

### Problema: Erro de conexão com a API

**Solução:** Verifique se o backend está rodando e se a URL em `NUXT_PUBLIC_API_BASE_URL` está correta. Como o SSR está desabilitado, use `localhost:3001` ou `0.0.0.0:3001`.

### Problema: Google Maps não carrega

**Solução:** 
1. Verifique se a chave da API está configurada no `.env`
2. Confirme se a **Maps JavaScript API** está ativada no Google Cloud Console
3. Verifique se há restrições de domínio na chave da API

### Problema: Erro ao instalar dependências

**Solução:** 
```bash
# Limpar cache e reinstalar
rm -rf node_modules yarn.lock
yarn install
```

### Problema: Porta 3000 já está em uso

**Solução:** Altere a porta no `nuxt.config.ts`:
```typescript
devServer: {
  port: 3001 // ou outra porta disponível
}
```

## 📄 Licença

Este projeto foi desenvolvido como parte de um desafio técnico.

---

**Desenvolvido com ❤️ para o desafio da Plathanus**

