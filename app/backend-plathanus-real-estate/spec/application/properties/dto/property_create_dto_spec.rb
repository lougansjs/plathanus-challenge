# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::Dto::PropertyCreateDto do
  describe "#initialize" do
    it "creates DTO with all attributes" do
      params = {
        name: "Test Property",
        status: "available",
        category_id: 1,
        rooms: 2,
        bathrooms: 1,
        area: 100,
        price: 1500,
        contract_type: "rent"
      }

      dto = described_class.new(params)

      expect(dto.name).to eq("Test Property")
      expect(dto.status).to eq("available")
      expect(dto.rooms).to eq(2)
      expect(dto.price).to eq(1500)
    end

    it "sets default values for arrays" do
      dto = described_class.new(name: "Test")

      expect(dto.rooms_list).to eq([])
      expect(dto.apartment_amenities).to eq([])
      expect(dto.building_characteristics).to eq([])
      expect(dto.photos).to eq([])
    end

    it "handles nil values" do
      dto = described_class.new({})

      expect(dto.name).to be_nil
      expect(dto.status).to be_nil
    end
  end
end

