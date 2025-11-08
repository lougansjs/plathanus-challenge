# frozen_string_literal: true

module Properties
  module Dto
    class PropertyCreateDto
      attr_accessor :name, :status, :category_id, :rooms, :bathrooms, :area,
                    :parking_slots, :furnished, :contract_type, :description,
                    :price, :promotional_price, :available_from, :rooms_list,
                    :apartment_amenities, :building_characteristics, :address, :photos

      def initialize(params)
        @name = params[:name]
        @status = params[:status]
        @category_id = params[:category_id]
        @rooms = params[:rooms]
        @bathrooms = params[:bathrooms]
        @area = params[:area]
        @parking_slots = params[:parking_slots]
        @furnished = params[:furnished]
        @contract_type = params[:contract_type]
        @description = params[:description]
        @price = params[:price]
        @promotional_price = params[:promotional_price]
        @available_from = params[:available_from]
        @rooms_list = params[:rooms_list] || []
        @apartment_amenities = params[:apartment_amenities] || []
        @building_characteristics = params[:building_characteristics] || []
        @address = params[:address]
        @photos = params[:photos] || []
      end
    end
  end
end