# frozen_string_literal: true

module Services
  class ImageVariantsService
    def self.urls_for(photo, host:)
      return {} unless photo&.blob # Proteção contra nil
      
      cache_key = "image_variants/#{photo.blob.id}/#{host}"

      Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        helpers = Rails.application.routes.url_helpers
        {
          thumb_url: helpers.rails_representation_url(
            photo.variant(resize_to_fill: [400, 300], format: :webp),
            host: host
          ),
          card_url: helpers.rails_representation_url(
            photo.variant(resize_to_fill: [800, 600], format: :webp),
            host: host
          ),
          cover_url: helpers.rails_representation_url(
            photo.variant(resize_to_fill: [1600, 900], format: :webp),
            host: host
          ),
          original_url: helpers.rails_blob_url(photo, host: host)
        }
      end
    end
  end
end