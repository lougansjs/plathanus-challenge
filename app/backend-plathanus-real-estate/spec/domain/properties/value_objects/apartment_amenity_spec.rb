# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::ValueObjects::ApartmentAmenity do
  describe ".validate_array" do
    it "returns empty array for nil" do
      expect(described_class.validate_array(nil)).to eq([])
    end

    it "returns empty array for empty array" do
      expect(described_class.validate_array([])).to eq([])
    end

    it "validates and returns valid amenities" do
      amenities = %w[wifi smart_tv oven]
      result = described_class.validate_array(amenities)
      expect(result).to eq(%w[wifi smart_tv oven])
    end

    it "raises error for invalid amenities" do
      amenities = %w[wifi invalid_amenity oven]
      expect {
        described_class.validate_array(amenities)
      }.to raise_error(ArgumentError, /Invalid apartment amenities/)
    end

    it "converts symbols to strings" do
      amenities = [:wifi, :smart_tv, :oven]
      result = described_class.validate_array(amenities)
      expect(result).to eq(%w[wifi smart_tv oven])
    end
  end

  describe ".valid?" do
    it "returns true for valid amenity" do
      expect(described_class.valid?("wifi")).to be true
    end

    it "returns false for invalid amenity" do
      expect(described_class.valid?("invalid")).to be false
    end
  end

  describe "#initialize" do
    it "creates valid amenity" do
      amenity = described_class.new("wifi")
      expect(amenity.value).to eq("wifi")
    end

    it "raises error for invalid amenity" do
      expect {
        described_class.new("invalid")
      }.to raise_error(ArgumentError, /Invalid apartment amenity/)
    end
  end
end

