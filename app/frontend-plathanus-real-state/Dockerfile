FROM node:20-alpine

RUN corepack enable && corepack prepare yarn@stable --activate

WORKDIR /app

COPY package.json yarn.lock ./

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY . .

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
