#!/bin/sh

echo "📦 Instalando dependências..."
yarn install

echo "🚀 Iniciando aplicação..."
exec yarn dev

