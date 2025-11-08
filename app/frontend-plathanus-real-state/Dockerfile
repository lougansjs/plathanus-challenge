# Dockerfile para desenvolvimento
FROM node:20-alpine

# Instalar yarn globalmente se não estiver disponível
RUN corepack enable && corepack prepare yarn@stable --activate

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY package.json yarn.lock ./

# Instalar dependências
RUN yarn install

# Copiar script de entrada
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copiar todo o código da aplicação
COPY . .

# Expor a porta 3000
EXPOSE 3000

# Usar o script de entrada que roda yarn install e depois inicia a aplicação
ENTRYPOINT ["/entrypoint.sh"]
