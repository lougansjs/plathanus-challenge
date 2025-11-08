class PropertySerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :code, :status, :rooms, :bathrooms, :area, :parking_slots,
             :furnished, :contract_type,
             :description, :price, :promotional_price,
             :available_from, :rooms_list, :apartment_amenities,
             :building_characteristics, :photos, :cover_photo, :created_at

  belongs_to :category
  has_one :address, serializer: AddressSerializer

  def photos
    return [] if object.blank? || object.photos.blank?

    host = default_host
    object.photos.map do |photo|
      next unless photo&.blob # Proteção contra nil
      
      urls = ::Services::ImageVariantsService.urls_for(photo, host: host)
      urls.merge(signed_id: photo.respond_to?(:signed_id) ? photo.signed_id : photo.blob.signed_id)
    end.compact
  end

  def cover_photo
    photo = object.respond_to?(:cover_photo) ? object.cover_photo : nil
    return nil unless photo

    host = default_host
    ::Services::ImageVariantsService.urls_for(photo, host: host)
  end

  private

  def default_host
    URI::HTTP.build(host: Rails.application.routes.default_url_options[:host],
                    port: Rails.application.routes.default_url_options[:port]).to_s
  end
end
