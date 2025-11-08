# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mappers::PropertyMapper do
  describe ".to_entity" do
    let(:category) { create(:category_record) }
    let(:property_record) { create(:property_record, category: category) }

    it "maps record to entity" do
      entity = described_class.to_entity(property_record)

      expect(entity).to be_a(Properties::Entities::Property)
      expect(entity.id).to eq(property_record.id)
      expect(entity.name).to eq(property_record.name)
      expect(entity.status_value).to eq(property_record.status)
    end

    it "returns nil for nil record" do
      expect(described_class.to_entity(nil)).to be_nil
    end

    it "maps category when present" do
      entity = described_class.to_entity(property_record)

      expect(entity.category).to be_a(Categories::Entities::Category)
      expect(entity.category.name).to eq(category.name)
    end

    it "maps address when present" do
      address_record = create(:address_record, property: property_record)
      property_record.reload

      entity = described_class.to_entity(property_record)

      expect(entity.address).to be_a(Properties::Entities::Address)
      expect(entity.address.street).to eq(address_record.street)
    end

    it "maps photos when present" do
      property_record.photos.attach(
        io: StringIO.new("fake image"),
        filename: "photo.jpg",
        content_type: "image/jpeg"
      )

      entity = described_class.to_entity(property_record)

      expect(entity.photos).not_to be_empty
    end
  end

  describe ".to_record" do
    let(:property_entity) do
      Properties::Entities::Property.new(
        name: "Test Property",
        status: "available",
        rooms: 2,
        bathrooms: 1,
        area: 100,
        price: 1500,
        contract_type: "rent"
      )
    end

    it "maps entity to new record" do
      record = described_class.to_record(property_entity)

      expect(record).to be_a(::Persistence::Models::PropertyRecord)
      expect(record.name).to eq("Test Property")
      expect(record.status).to eq("available")
      expect(record.rooms).to eq(2)
    end

    it "maps entity to existing record" do
      existing_record = create(:property_record)
      record = described_class.to_record(property_entity, existing_record)

      expect(record.id).to eq(existing_record.id)
      expect(record.name).to eq("Test Property")
    end

    it "maps value objects correctly" do
      record = described_class.to_record(property_entity)

      expect(record.status).to eq("available")
      expect(record.contract_type).to eq("rent")
      expect(record.price).to eq(1500.0)
    end
  end

  describe ".to_dto" do
    let(:property_entity) do
      Properties::Entities::Property.new(
        id: 1,
        name: "Test Property",
        status: "available"
      )
    end

    it "maps entity to DTO" do
      dto = described_class.to_dto(property_entity)

      expect(dto).to be_a(Properties::Dto::PropertyDto)
      expect(dto.id).to eq(1)
      expect(dto.name).to eq("Test Property")
    end

    it "returns nil for nil entity" do
      expect(described_class.to_dto(nil)).to be_nil
    end
  end
end

