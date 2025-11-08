# frozen_string_literal: true

module Properties
  module Services
    class PropertyPhotoService
      MIN_PHOTOS = 3
      MAX_PHOTOS = 5
      MAX_FILE_SIZE = 10.megabytes
      ALLOWED_CONTENT_TYPES = ["image/jpg", "image/jpeg", "image/png", "image/webp"].freeze

      def self.validate_for_create(photos)
        photos_array = Array(photos)
        count = photos_array.size
        unless count.between?(MIN_PHOTOS, MAX_PHOTOS)
          raise ArgumentError, "Photos deve ter entre #{MIN_PHOTOS} e #{MAX_PHOTOS} fotos"
        end

        # Validar cada foto individualmente
        photos_array.each_with_index do |photo, index|
          validate_photo(photo, index)
        end
      end

      def self.validate_for_update(existing_count, new_photos)
        new_count = Array(new_photos).size
        total = existing_count + new_count
        if total > MAX_PHOTOS
          raise ArgumentError, "Não pode exceder #{MAX_PHOTOS} fotos. Atualmente: #{existing_count}, tentando adicionar: #{new_count}"
        end

        # Validar cada nova foto
        Array(new_photos).each_with_index do |photo, index|
          validate_photo(photo, index)
        end
      end

      def self.validate_for_delete(remaining_count)
        if remaining_count < MIN_PHOTOS
          raise ArgumentError, "Não é possível deletar. O imóvel deve ter pelo menos #{MIN_PHOTOS} fotos"
        end
      end

      def self.validate_photo(photo, index = 0)
        # Validar content type
        content_type = extract_content_type(photo)
        unless ALLOWED_CONTENT_TYPES.include?(content_type)
          raise ArgumentError, "Foto #{index + 1}: tipo de arquivo inválido. Apenas JPEG, PNG e WebP são permitidos"
        end

        # Validar tamanho
        file_size = extract_file_size(photo)
        if file_size > MAX_FILE_SIZE
          raise ArgumentError, "Foto #{index + 1}: arquivo muito grande. Tamanho máximo: 10MB"
        end

        # Validar assinatura do arquivo (magic bytes)
        unless valid_file_signature?(photo, content_type)
          raise ArgumentError, "Foto #{index + 1}: arquivo corrompido ou tipo inválido detectado"
        end
      end

      private

      def self.extract_content_type(photo)
        if photo.respond_to?(:content_type)
          photo.content_type
        elsif photo.respond_to?(:contentType)
          photo.contentType
        elsif photo.is_a?(ActionDispatch::Http::UploadedFile)
          photo.content_type
        else
          # Tentar detectar pelo nome do arquivo
          filename = extract_filename(photo)
          case File.extname(filename).downcase
          when ".jpg", ".jpeg"
            "image/jpeg"
          when ".png"
            "image/png"
          when ".webp"
            "image/webp"
          else
            raise ArgumentError, "Tipo de arquivo não suportado: #{File.extname(filename)}"
          end
        end
      end

      def self.extract_file_size(photo)
        if photo.respond_to?(:size)
          photo.size
        elsif photo.respond_to?(:byte_size)
          photo.byte_size
        elsif photo.is_a?(ActionDispatch::Http::UploadedFile)
          photo.size
        elsif photo.respond_to?(:read)
          # Para arquivos abertos, precisamos ler para obter o tamanho
          original_pos = photo.pos
          photo.rewind
          size = photo.size || photo.read.bytesize
          photo.pos = original_pos
          size
        else
          raise ArgumentError, "Não foi possível determinar o tamanho do arquivo"
        end
      end

      def self.extract_filename(photo)
        if photo.respond_to?(:original_filename)
          photo.original_filename
        elsif photo.respond_to?(:filename)
          photo.filename
        elsif photo.is_a?(ActionDispatch::Http::UploadedFile)
          photo.original_filename
        else
          "unknown"
        end
      end

      def self.valid_file_signature?(photo, content_type)
        return false unless photo

        begin
          # Ler os primeiros bytes do arquivo
          signature = read_file_signature(photo)

          case content_type
          when "image/jpeg"
            jpeg_signatures = ["\xFF\xD8\xFF".b]
            jpeg_signatures.any? { |sig| signature.start_with?(sig) }
          when "image/png"
            png_signature = "\x89PNG\r\n\x1A\n".b
            signature.start_with?(png_signature)
          when "image/webp"
            webp_signature = "RIFF".b
            signature.start_with?(webp_signature) && signature[8..11] == "WEBP".b
          else
            false
          end
        rescue StandardError => e
          Rails.logger.error "Erro ao validar assinatura do arquivo: #{e.message}"
          false
        end
      end

      def self.read_file_signature(photo)
        if photo.respond_to?(:read)
          original_pos = photo.pos if photo.respond_to?(:pos)
          photo.rewind if photo.respond_to?(:rewind)
          signature = photo.read(12)
          photo.pos = original_pos if photo.respond_to?(:pos=) && original_pos
          signature || "".b
        elsif photo.respond_to?(:open)
          photo.open do |io|
            io.read(12) || "".b
          end
        elsif photo.is_a?(ActionDispatch::Http::UploadedFile)
          photo.rewind
          signature = photo.read(12)
          photo.rewind
          signature || "".b
        else
          "".b
        end
      end
    end
  end
end
