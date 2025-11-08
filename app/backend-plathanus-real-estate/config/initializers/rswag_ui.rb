# frozen_string_literal: true

Rswag::Ui.configure do |c|
  # Lista os arquivos Swagger a serem expostos na UI
  # O caminho deve ser o caminho completo a partir da raiz da aplicação
  # Como o rswag-api está montado em /api-docs e o arquivo está em swagger/v1/swagger.yaml,
  # o caminho completo é /api-docs/v1/swagger.yaml
  # Nota: swagger_endpoint será renomeado para openapi_endpoint na v3.0
  if c.respond_to?(:openapi_endpoint)
    c.openapi_endpoint "/api-docs/v1/swagger.yaml", "API V1 Docs"
  else
    c.swagger_endpoint "/api-docs/v1/swagger.yaml", "API V1 Docs"
  end

  # Configurações adicionais
  # O URL deve ser o caminho completo a partir da raiz
  c.config_object = {
    url: "/api-docs/v1/swagger.yaml",
    validatorUrl: nil
  }
end
