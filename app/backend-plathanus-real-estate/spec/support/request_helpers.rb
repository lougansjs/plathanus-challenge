# frozen_string_literal: true

module RequestHelpers
  def json_response
    JSON.parse(response.body)
  end

  def json_response_symbolized
    JSON.parse(response.body, symbolize_names: true)
  end

  def upload_file(filename = "test_image.jpg", content_type = "image/jpeg")
    # Cria um arquivo temporário para upload com assinatura JPEG válida
    file = Tempfile.new([filename.split(".").first, ".jpg"])
    file.binmode
    # Assinatura JPEG válida (magic bytes)
    file.write("\xFF\xD8\xFF\xE0\x00\x10JFIF".b)
    file.write("fake image content" * 100) # Adiciona conteúdo suficiente
    file.rewind
    Rack::Test::UploadedFile.new(file.path, content_type)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end

