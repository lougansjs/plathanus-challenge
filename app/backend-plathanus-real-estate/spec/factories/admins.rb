# frozen_string_literal: true

FactoryBot.define do
  factory :admin_record, class: "Persistence::Models::AdminRecord" do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
  end

  factory :admin_entity, class: "Authentication::Entities::Admin" do
    id { 1 }
    email { Faker::Internet.unique.email }
    password_digest { BCrypt::Password.create("password123") }
  end
end
