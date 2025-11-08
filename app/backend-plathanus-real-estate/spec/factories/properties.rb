# frozen_string_literal: true

FactoryBot.define do
  factory :property_record, class: "Persistence::Models::PropertyRecord" do
    name { Faker::Commerce.product_name }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 10) }
    status { "available" }
    rooms { Faker::Number.between(from: 1, to: 5) }
    bathrooms { Faker::Number.between(from: 1, to: 4) }
    area { Faker::Number.between(from: 50, to: 500) }
    parking_slots { Faker::Number.between(from: 0, to: 3) }
    furnished { false }
    contract_type { "rent" }
    description { Faker::Lorem.paragraph }
    price { Faker::Number.between(from: 500, to: 5000) }
    promotional_price { nil }
    available_from { Faker::Date.forward(days: 30) }
    rooms_list { [] }
    apartment_amenities { [] }
    building_characteristics { [] }
    association :category, factory: :category_record

    trait :with_address do
      after(:create) do |property|
        create(:address_record, property: property)
      end
    end

    trait :with_photos do
      after(:create) do |property|
        # Cria arquivos temporários para fotos
        3.times do
          file = Tempfile.new(["photo", ".jpg"])
          file.write("fake image content")
          file.rewind
          property.photos.attach(
            io: file,
            filename: "photo.jpg",
            content_type: "image/jpeg"
          )
        end
      end
    end
  end

  factory :property_entity, class: "Properties::Entities::Property" do
    id { 1 }
    name { Faker::Commerce.product_name }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 10) }
    status { "available" }
    rooms { Faker::Number.between(from: 1, to: 5) }
    bathrooms { Faker::Number.between(from: 1, to: 4) }
    area { Faker::Number.between(from: 50, to: 500) }
    parking_slots { Faker::Number.between(from: 0, to: 3) }
    furnished { false }
    contract_type { "rent" }
    description { Faker::Lorem.paragraph }
    price { Faker::Number.between(from: 500, to: 5000) }
    promotional_price { nil }
    available_from { Faker::Date.forward(days: 30) }
    rooms_list { [] }
    apartment_amenities { [] }
    building_characteristics { [] }
    category_id { 1 }
    photos { [] }
  end
end
