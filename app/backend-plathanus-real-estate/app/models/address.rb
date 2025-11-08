# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :property

  validates :street, :neighborhood, :city, :state, :country, :zipcode, presence: true
  validates :latitude, :longitude, numericality: {
          allow_nil: true,
          greater_than_or_equal_to: -90,
          less_than_or_equal_to: 90 }
end
