# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::ValueObjects::Price do
  describe "#initialize" do
    it "creates a valid price" do
      price = described_class.new(1000.50)
      expect(price.value).to eq(1000.50)
    end

    it "accepts integer values" do
      price = described_class.new(1000)
      expect(price.value).to eq(1000.0)
    end

    it "raises error for non-numeric value" do
      expect { described_class.new("1000") }.to raise_error(ArgumentError, /Price must be a number/)
    end

    it "raises error for negative value" do
      expect { described_class.new(-100) }.to raise_error(ArgumentError, /Price must be greater than or equal to 0/)
    end

    it "accepts zero" do
      price = described_class.new(0)
      expect(price.value).to eq(0.0)
    end
  end

  describe "#to_f" do
    it "returns the price as float" do
      price = described_class.new(1000.50)
      expect(price.to_f).to eq(1000.50)
    end
  end

  describe "#to_s" do
    it "returns the price as string" do
      price = described_class.new(1000.50)
      expect(price.to_s).to eq("1000.5")
    end
  end

  describe "#==" do
    it "returns true for equal prices" do
      price1 = described_class.new(1000)
      price2 = described_class.new(1000)
      expect(price1).to eq(price2)
    end

    it "returns false for different prices" do
      price1 = described_class.new(1000)
      price2 = described_class.new(2000)
      expect(price1).not_to eq(price2)
    end

    it "returns false for different types" do
      price = described_class.new(1000)
      expect(price).not_to eq(1000)
    end
  end
end

