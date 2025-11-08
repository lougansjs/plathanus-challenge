# frozen_string_literal: true

module Properties
  module Dto
    class PropertyFilterDto
      attr_accessor :search, :city, :rooms, :rooms_min, :bathrooms, :parking_slots,
                    :price_min, :price_max, :furnished, :apartment_amenities,
                    :building_characteristics, :pets_allowed, :order, :page, :per_page

      def initialize(params)
        @search = params[:search] || params[:q]
        @city = params[:city]
        @rooms = params[:rooms]
        @rooms_min = params[:rooms_min]
        @bathrooms = params[:bathrooms]
        @parking_slots = params[:parking_slots]
        @price_min = params[:price_min]
        @price_max = params[:price_max]
        @furnished = params[:furnished]
        @apartment_amenities = params[:apartment_amenities]
        @building_characteristics = params[:building_characteristics]
        @pets_allowed = params[:pets_allowed]
        @order = params[:order] || "recent"
        @page = params[:page] || 1
        @per_page = [params[:per_page]&.to_i || 12, 100].min
      end
    end
  end
end