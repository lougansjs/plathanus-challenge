# frozen_string_literal: true

FactoryBot.define do
  factory :address_record, class: "Persistence::Models::AddressRecord" do
    street { Faker::Address.street_address }
    neighborhood { Faker::Address.community }
    city { Faker::Address.city }
    state { Faker::Address.state }
    country { "Brasil" }
    zipcode { Faker::Address.zip_code }
    latitude { Faker::Number.between(from: -90.0, to: 90.0).round(6) }
    longitude { Faker::Number.between(from: -180.0, to: 180.0).round(6) }
    association :property, factory: :property_record
  end

  factory :address_entity, class: "Properties::Entities::Address" do
    id { 1 }
    street { Faker::Address.street_address }
    neighborhood { Faker::Address.community }
    city { Faker::Address.city }
    state { Faker::Address.state }
    country { "Brasil" }
    zipcode { Faker::Address.zip_code }
    latitude { Faker::Number.between(from: -90.0, to: 90.0).round(6) }
    longitude { Faker::Number.between(from: -180.0, to: 180.0).round(6) }
  end
end
