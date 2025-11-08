# frozen_string_literal: true

module Properties
  module ValueObjects
    class PhotoCollection
      MIN_PHOTOS = 3
      MAX_PHOTOS = 5
      MAX_SIZE = 10.megabytes
      ALLOWED_TYPES = %w[image/jpeg image/png image/webp].freeze

      attr_reader :photos

      def initialize(photos)
        @photos = Array(photos)
      end

      def count
        @photos.size
      end

      def valid_count_for_create?
        count.between?(MIN_PHOTOS, MAX_PHOTOS)
      end

      def valid_count_for_update?(existing_count)
        (existing_count + count).between?(MIN_PHOTOS, MAX_PHOTOS)
      end

      def valid_count_for_delete?(remaining_count)
        remaining_count >= MIN_PHOTOS
      end

      def validate_photo(photo)
        errors = []

        # Valida tipo
        unless ALLOWED_TYPES.include?(photo_content_type(photo))
          errors << "tipo de arquivo inválido. Apenas JPEG, PNG e WebP são permitidos"
          return errors
        end

        # Valida tamanho
        size = photo_size(photo)
        if size > MAX_SIZE
          errors << "arquivo muito grande. Tamanho máximo: 10MB"
        end

        # Valida magic bytes (se possível)
        unless valid_file_signature?(photo)
          errors << "arquivo corrompido ou tipo inválido detectado"
        end

        errors
      end

      private

      def photo_content_type(photo)
        if photo.respond_to?(:content_type)
          photo.content_type
        elsif photo.respond_to?(:blob)
          photo.blob.content_type
        else
          nil
        end
      end

      def photo_size(photo)
        if photo.respond_to?(:size)
          photo.size
        elsif photo.respond_to?(:byte_size)
          photo.byte_size
        elsif photo.respond_to?(:blob)
          photo.blob.byte_size
        else
          0
        end
      end

      def valid_file_signature?(photo)
        return false unless photo.respond_to?(:blob) || photo.respond_to?(:download)

        begin
          blob = photo.respond_to?(:blob) ? photo.blob : photo
          return false unless blob.respond_to?(:downloadable?) && blob.downloadable?

          io = blob.download
          signature = io.read(12)
          io.close

          content_type = photo_content_type(photo)
          jpeg_signatures = ["\xFF\xD8\xFF".b]
          png_signature = "\x89PNG\r\n\x1A\n".b
          webp_signature = "RIFF".b

          case content_type
          when "image/jpeg"
            jpeg_signatures.any? { |sig| signature.start_with?(sig) }
          when "image/png"
            signature.start_with?(png_signature)
          when "image/webp"
            signature.start_with?(webp_signature) && signature[8..11] == "WEBP".b
          else
            false
          end
        rescue StandardError => e
          Rails.logger.error "Erro ao validar assinatura do arquivo: #{e.message}"
          false
        end
      end
    end
  end
end