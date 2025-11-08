# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::Dto::PropertyDto do
  describe "#initialize" do
    let(:property_entity) do
      Properties::Entities::Property.new(
        id: 1,
        name: "Test Property",
        status: "available",
        rooms: 2,
        bathrooms: 1,
        area: 100,
        price: 1500,
        contract_type: "rent"
      )
    end

    it "creates DTO from entity" do
      dto = described_class.new(property_entity)

      expect(dto.id).to eq(1)
      expect(dto.name).to eq("Test Property")
      expect(dto.status).to eq("available")
      expect(dto.rooms).to eq(2)
      expect(dto.price).to eq(1500.0)
    end

    it "maps value objects to strings" do
      dto = described_class.new(property_entity)

      expect(dto.status).to eq("available")
      expect(dto.contract_type).to eq("rent")
    end

    it "includes cover photo" do
      photos = [double("photo1"), double("photo2"), double("photo3")]
      property_entity.photos = photos

      dto = described_class.new(property_entity)

      expect(dto.cover_photo).to eq(photos[2])
    end
  end
end

