# frozen_string_literal: true

module Persistence
  module ActiveRecord
    class PropertyRepositoryImpl < Properties::Repositories::PropertyRepository
      include ::Helpers::ParameterHelpers

      def find(id)
        record = ::Persistence::Models::PropertyRecord
          .includes(:category, :address, photos_attachments: { blob: :variant_records })
          .find(id)
        ::Mappers::PropertyMapper.to_entity(record)
      end

      def all(filters: {}, order: { created_at: :desc }, page: 1, per_page: 12)
        scope = ::Persistence::Models::PropertyRecord
          .includes(:category, :address, photos_attachments: :blob)

        scope = apply_filters(scope, filters)
        scope = scope.order(order)

        paginated = scope.page(page).per(per_page)

        {
          properties: paginated.map { |record| ::Mappers::PropertyMapper.to_entity(record) },
          meta: {
            page: paginated.current_page,
            per_page: paginated.limit_value,
            total_pages: paginated.total_pages,
            total_count: paginated.total_count
          }
        }
      end

      def create(property, photos: [])
        record = ::Mappers::PropertyMapper.to_record(property)
        record.save!

        # Anexar fotos
        Array(photos).each { |photo| record.photos.attach(photo) }

        # Criar endereço se fornecido
        if property.address
          address_record = ::Mappers::AddressMapper.to_record(property.address)
          address_record.property = record
          address_record.save!
        end

        ::Mappers::PropertyMapper.to_entity(record.reload)
      end

      def update(property, photos: [])
        record = ::Persistence::Models::PropertyRecord.find(property.id)
        ::Mappers::PropertyMapper.to_record(property, record)
        record.save!

        # Anexar novas fotos se houver
        Array(photos).each { |photo| record.photos.attach(photo) }

        # Atualizar endereço
        if property.address
          if record.address
            ::Mappers::AddressMapper.to_record(property.address, record.address)
            record.address.save!
          else
            address_record = ::Mappers::AddressMapper.to_record(property.address)
            address_record.property = record
            address_record.save!
          end
        end

        ::Mappers::PropertyMapper.to_entity(record.reload)
      end

      def delete(id)
        record = ::Persistence::Models::PropertyRecord.find(id)
        record.destroy!
      end

      def delete_photo(property_id, signed_id)
        record = ::Persistence::Models::PropertyRecord.find(property_id)
        begin
          blob = ActiveStorage::Blob.find_signed(signed_id)
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          raise ActiveSupport::MessageVerifier::InvalidSignature, "ID de foto inválido"
        end
        
        # Se find_signed retornar nil (string inválida), também lança exceção
        unless blob
          raise ActiveSupport::MessageVerifier::InvalidSignature, "ID de foto inválido"
        end

        attachment = record.photos_attachments.find_by(blob_id: blob.id)
        attachment&.purge
      end

      private

      def apply_filters(scope, filters)
        s = scope

        # Search
        if (term = filters[:search]&.presence)
          like = "%#{term[0..100]}%"
          s = s.left_joins(:address).where(
            <<~SQL.squish, like: like, like2: like
              properties.name ILIKE :like
              OR properties.description ILIKE :like
              OR addresses.city ILIKE :like2
              OR addresses.neighborhood ILIKE :like2
            SQL
          )
        end

        # City
        if (city = filters[:city]&.presence)
          s = s.joins(:address).where("addresses.city ILIKE ?", "%#{city}%")
        end

        # Rooms
        if filters[:rooms].present?
          rooms_array = Array(filters[:rooms]).map { |r| safe_integer(r) }.compact
          s = s.where("properties.rooms IN (?)", rooms_array) if rooms_array.any?
        elsif (min_rooms = filters[:rooms_min]&.presence)
          min_rooms_int = safe_integer(min_rooms)
          s = s.where("properties.rooms >= ?", min_rooms_int) if min_rooms_int
        end

        # Bathrooms
        if filters[:bathrooms].present?
          bathrooms_array = Array(filters[:bathrooms]).map { |b| safe_integer(b) }.compact
          s = s.where("properties.bathrooms IN (?)", bathrooms_array) if bathrooms_array.any?
        end

        # Parking slots
        if filters[:parking_slots].present?
          parking_array = Array(filters[:parking_slots]).map { |p| safe_integer(p) }.compact
          s = s.where("properties.parking_slots IN (?)", parking_array) if parking_array.any?
        end

        # Price range
        if filters[:price_min].present?
          price_min_float = safe_float(filters[:price_min])
          s = s.where("properties.price >= ?", price_min_float) if price_min_float
        end
        if filters[:price_max].present?
          price_max_float = safe_float(filters[:price_max])
          s = s.where("properties.price <= ?", price_max_float) if price_max_float
        end

        # Furnished
        if filters[:furnished].present?
          val = ActiveModel::Type::Boolean.new.cast(filters[:furnished])
          s = s.where(furnished: val)
        end

        # Apartment amenities
        if filters[:apartment_amenities].present?
          amenities_array = sanitize_amenities(filters[:apartment_amenities])
          s = s.where("apartment_amenities && ARRAY[?]::text[]", amenities_array) if amenities_array.any?
        end

        # Building characteristics
        if filters[:building_characteristics].present?
          characteristics_array = sanitize_characteristics(filters[:building_characteristics])
          s = s.where("building_characteristics && ARRAY[?]::text[]", characteristics_array) if characteristics_array.any?
        end

        # Pets allowed
        if filters[:pets_allowed].present?
          val = ActiveModel::Type::Boolean.new.cast(filters[:pets_allowed])
          s = s.where("'pets_allowed' = ANY(building_characteristics)") if val
        end

        s
      end
    end
  end
end