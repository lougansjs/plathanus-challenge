# frozen_string_literal: true

FactoryBot.define do
  factory :category_record, class: "Persistence::Models::CategoryRecord" do
    name { Faker::Commerce.unique.department }
  end

  factory :category_entity, class: "Categories::Entities::Category" do
    id { 1 }
    name { Faker::Commerce.unique.department }
  end
end
