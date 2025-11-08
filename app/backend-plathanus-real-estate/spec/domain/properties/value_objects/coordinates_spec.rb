# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::ValueObjects::Coordinates do
  describe "#initialize" do
    it "creates valid coordinates" do
      coords = described_class.new(latitude: -23.5505, longitude: -46.6333)
      expect(coords.latitude).to eq(-23.5505)
      expect(coords.longitude).to eq(-46.6333)
    end

    it "raises error for invalid latitude" do
      expect { described_class.new(latitude: 91, longitude: 0) }.to raise_error(ArgumentError, /Latitude/)
    end

    it "raises error for invalid longitude" do
      expect { described_class.new(latitude: 0, longitude: 181) }.to raise_error(ArgumentError, /Longitude/)
    end

    it "accepts nil values" do
      coords = described_class.new(latitude: nil, longitude: nil)
      expect(coords.latitude).to be_nil
      expect(coords.longitude).to be_nil
    end

    it "raises error for latitude below -90" do
      expect { described_class.new(latitude: -91, longitude: 0) }.to raise_error(ArgumentError, /Latitude/)
    end

    it "raises error for longitude above 180" do
      expect { described_class.new(latitude: 0, longitude: 181) }.to raise_error(ArgumentError, /Longitude/)
    end

    it "raises error for longitude below -180" do
      expect { described_class.new(latitude: 0, longitude: -181) }.to raise_error(ArgumentError, /Longitude/)
    end
  end

  describe "boundary values" do
    it "accepts maximum latitude" do
      coords = described_class.new(latitude: 90, longitude: 0)
      expect(coords.latitude).to eq(90)
    end

    it "accepts minimum latitude" do
      coords = described_class.new(latitude: -90, longitude: 0)
      expect(coords.latitude).to eq(-90)
    end

    it "accepts maximum longitude" do
      coords = described_class.new(latitude: 0, longitude: 180)
      expect(coords.longitude).to eq(180)
    end

    it "accepts minimum longitude" do
      coords = described_class.new(latitude: 0, longitude: -180)
      expect(coords.longitude).to eq(-180)
    end
  end
end

