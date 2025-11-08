# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::Entities::Property do
  describe "#initialize" do
    it "creates a property with all attributes" do
      property = described_class.new(
        id: 1,
        name: "Test Property",
        status: "available",
        rooms: 2,
        bathrooms: 1,
        area: 100,
        price: 1500
      )

      expect(property.id).to eq(1)
      expect(property.name).to eq("Test Property")
      expect(property.rooms).to eq(2)
      expect(property.bathrooms).to eq(1)
      expect(property.area).to eq(100)
    end

    it "sets default values" do
      property = described_class.new(name: "Test")

      expect(property.furnished).to be false
      expect(property.rooms_list).to eq([])
      expect(property.apartment_amenities).to eq([])
      expect(property.building_characteristics).to eq([])
      expect(property.photos).to eq([])
    end
  end

  describe "#status=" do
    it "accepts string value" do
      property = described_class.new
      property.status = "available"
      expect(property.status_value).to eq("available")
    end

    it "accepts PropertyStatus value object" do
      property = described_class.new
      status = Properties::ValueObjects::PropertyStatus.new("available")
      property.status = status
      expect(property.status).to eq(status)
    end
  end

  describe "#contract_type=" do
    it "accepts string value" do
      property = described_class.new
      property.contract_type = "rent"
      expect(property.contract_type_value).to eq("rent")
    end

    it "accepts ContractType value object" do
      property = described_class.new
      contract_type = Properties::ValueObjects::ContractType.new("rent")
      property.contract_type = contract_type
      expect(property.contract_type).to eq(contract_type)
    end
  end

  describe "#price=" do
    it "accepts numeric value" do
      property = described_class.new
      property.price = 1500.50
      expect(property.price_value).to eq(1500.50)
    end

    it "accepts Price value object" do
      property = described_class.new
      price = Properties::ValueObjects::Price.new(1500)
      property.price = price
      expect(property.price).to eq(price)
    end
  end

  describe "#cover_photo" do
    it "returns the third photo" do
      photos = [double("photo1"), double("photo2"), double("photo3")]
      property = described_class.new(photos: photos)

      expect(property.cover_photo).to eq(photos[2])
    end

    it "returns nil when there are less than 3 photos" do
      photos = [double("photo1"), double("photo2")]
      property = described_class.new(photos: photos)

      expect(property.cover_photo).to be_nil
    end
  end
end

