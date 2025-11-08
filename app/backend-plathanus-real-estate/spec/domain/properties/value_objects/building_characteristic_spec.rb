# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::ValueObjects::BuildingCharacteristic do
  describe ".validate_array" do
    it "returns empty array for nil" do
      expect(described_class.validate_array(nil)).to eq([])
    end

    it "returns empty array for empty array" do
      expect(described_class.validate_array([])).to eq([])
    end

    it "validates and returns valid characteristics" do
      characteristics = %w[parking pets_allowed gym]
      result = described_class.validate_array(characteristics)
      expect(result).to eq(%w[parking pets_allowed gym])
    end

    it "raises error for invalid characteristics" do
      characteristics = %w[parking invalid_char gym]
      expect {
        described_class.validate_array(characteristics)
      }.to raise_error(ArgumentError, /Invalid building characteristics/)
    end

    it "converts symbols to strings" do
      characteristics = [:parking, :pets_allowed, :gym]
      result = described_class.validate_array(characteristics)
      expect(result).to eq(%w[parking pets_allowed gym])
    end
  end

  describe ".valid?" do
    it "returns true for valid characteristic" do
      expect(described_class.valid?("parking")).to be true
    end

    it "returns false for invalid characteristic" do
      expect(described_class.valid?("invalid")).to be false
    end
  end

  describe "#initialize" do
    it "creates valid characteristic" do
      characteristic = described_class.new("parking")
      expect(characteristic.value).to eq("parking")
    end

    it "raises error for invalid characteristic" do
      expect {
        described_class.new("invalid")
      }.to raise_error(ArgumentError, /Invalid building characteristic/)
    end
  end
end

