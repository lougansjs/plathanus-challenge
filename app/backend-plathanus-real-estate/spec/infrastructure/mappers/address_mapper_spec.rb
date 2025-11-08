# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mappers::AddressMapper do
  describe ".to_entity" do
    let(:address_record) { create(:address_record) }

    it "maps record to entity" do
      entity = described_class.to_entity(address_record)

      expect(entity).to be_a(Properties::Entities::Address)
      expect(entity.id).to eq(address_record.id)
      expect(entity.street).to eq(address_record.street)
      expect(entity.city).to eq(address_record.city)
    end

    it "maps coordinates when present" do
      address_record.update(latitude: -23.5505, longitude: -46.6333)

      entity = described_class.to_entity(address_record)

      expect(entity.latitude).to eq(-23.5505)
      expect(entity.longitude).to eq(-46.6333)
    end

    it "returns nil for nil record" do
      expect(described_class.to_entity(nil)).to be_nil
    end
  end

  describe ".to_record" do
    let(:address_entity) do
      Properties::Entities::Address.new(
        street: "Rua Test",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567",
        latitude: -23.5505,
        longitude: -46.6333
      )
    end

    it "maps entity to new record" do
      record = described_class.to_record(address_entity)

      expect(record).to be_a(::Persistence::Models::AddressRecord)
      expect(record.street).to eq("Rua Test")
      expect(record.city).to eq("São Paulo")
    end

    it "maps entity to existing record" do
      existing_record = create(:address_record)
      record = described_class.to_record(address_entity, existing_record)

      expect(record.id).to eq(existing_record.id)
      expect(record.street).to eq("Rua Test")
    end

    it "maps coordinates correctly" do
      record = described_class.to_record(address_entity)

      expect(record.latitude).to eq(-23.5505)
      expect(record.longitude).to eq(-46.6333)
    end
  end
end

