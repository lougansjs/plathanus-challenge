# frozen_string_literal: true

module Properties
  module Services
    class PropertyFilterService
      def self.build_filters(params)
        return {} if params.nil?

        {
          search: params[:search] || params[:q],
          city: params[:city],
          rooms: params[:rooms],
          rooms_min: params[:rooms_min],
          bathrooms: params[:bathrooms],
          parking_slots: params[:parking_slots],
          price_min: params[:price_min],
          price_max: params[:price_max],
          furnished: params[:furnished],
          apartment_amenities: params[:apartment_amenities],
          building_characteristics: params[:building_characteristics],
          pets_allowed: params[:pets_allowed]
        }
      end

      def self.build_order(order_param)
        ORDER_MAP[order_param.to_s] || ORDER_MAP["recent"]
      end

      ORDER_MAP = {
        "recent" => { created_at: :desc },
        "price_asc" => { price: :asc },
        "price_desc" => { price: :desc },
        "area_desc" => { area: :desc }
      }.freeze
    end
  end
end