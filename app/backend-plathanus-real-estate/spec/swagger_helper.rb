# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Especifica o formato de saída do Swagger
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define os formatos aceitos
  config.openapi_format = :json
end

