# frozen_string_literal: true

class AddressSerializer < ActiveModel::Serializer
  attributes :street, :neighborhood, :city, :state, :country, :zipcode, :latitude, :longitude
end
