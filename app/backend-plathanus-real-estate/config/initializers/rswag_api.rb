# frozen_string_literal: true

Rswag::Api.configure do |c|
  # Especifica o caminho raiz do OpenAPI/Swagger
  # O rswag-api procura automaticamente por arquivos .yaml/.json neste diretório
  c.openapi_root = Rails.root.join("swagger").to_s
end

