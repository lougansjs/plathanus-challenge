# frozen_string_literal: true

class ProcessPropertyPhotosJob < ApplicationJob
  queue_as :default

  def perform(property_id)
    property = ::Persistence::Models::PropertyRecord.find_by(id: property_id)
    return unless property&.photos&.attached?

    property.photos.each do |photo|
      process_photo_variants(photo)
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info("ProcessPropertyPhotosJob: Property #{property_id} not found, skipping")
  rescue StandardError => e
    Rails.logger.error("ProcessPropertyPhotosJob failed for property #{property_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
  end

  private

  def process_photo_variants(photo)
    photo.variant(resize_to_fill: [400, 300], format: :webp).processed
    photo.variant(resize_to_fill: [800, 600], format: :webp).processed
    photo.variant(resize_to_fill: [1600, 900], format: :webp).processed
    Rails.logger.info("ProcessPropertyPhotosJob: Processed variants for photo #{photo.blob.id}")
  rescue ActiveStorage::FileNotFoundError
    Rails.logger.warn("ProcessPropertyPhotosJob: Photo #{photo.blob.id} file not found, will retry")
    raise
  end
end
