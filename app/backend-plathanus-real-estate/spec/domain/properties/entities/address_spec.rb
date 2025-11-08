# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::Entities::Address do
  describe "#initialize" do
    it "creates an address with all attributes" do
      address = described_class.new(
        id: 1,
        street: "Rua Test",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567",
        latitude: -23.5505,
        longitude: -46.6333
      )

      expect(address.street).to eq("Rua Test")
      expect(address.city).to eq("São Paulo")
      expect(address.latitude).to eq(-23.5505)
      expect(address.longitude).to eq(-46.6333)
    end

    it "creates coordinates when latitude and longitude are provided" do
      address = described_class.new(
        latitude: -23.5505,
        longitude: -46.6333
      )

      expect(address.coordinates).to be_a(Properties::ValueObjects::Coordinates)
      expect(address.latitude).to eq(-23.5505)
      expect(address.longitude).to eq(-46.6333)
    end

    it "does not create coordinates when latitude and longitude are nil" do
      address = described_class.new(
        street: "Rua Test",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      )

      expect(address.coordinates).to be_nil
      expect(address.latitude).to be_nil
      expect(address.longitude).to be_nil
    end
  end

  describe "#valid?" do
    it "returns true when all required fields are present" do
      address = described_class.new(
        street: "Rua Test",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      )

      expect(address.valid?).to be true
    end

    it "returns false when any required field is missing" do
      address = described_class.new(
        street: "Rua Test",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil"
        # zipcode missing
      )

      expect(address.valid?).to be false
    end

    it "returns false when street is blank" do
      address = described_class.new(
        street: "",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      )

      expect(address.valid?).to be false
    end
  end
end

