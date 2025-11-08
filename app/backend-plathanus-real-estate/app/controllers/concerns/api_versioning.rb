# frozen_string_literal: true

module ApiVersioning
  extend ActiveSupport::Concern

  included do
    # Versão atual da API
    API_VERSION = "1.0.0".freeze

    # Adiciona header de versão em todas as respostas
    after_action :add_api_version_header
  end

  private

  def add_api_version_header
    response.headers["API-Version"] = API_VERSION
    response.headers["X-API-Version"] = API_VERSION # Compatibilidade
  end
end

