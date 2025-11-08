# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::ValueObjects::ContractType do
  describe "#initialize" do
    it "creates a valid contract type" do
      contract_type = described_class.new("rent")
      expect(contract_type.value).to eq("rent")
    end

    it "raises error for invalid contract type" do
      expect { described_class.new("sale") }.to raise_error(ArgumentError, /Invalid contract type/)
    end

    it "converts symbol to string" do
      contract_type = described_class.new(:rent)
      expect(contract_type.value).to eq("rent")
    end
  end

  describe "#to_s" do
    it "returns the contract type as string" do
      contract_type = described_class.new("rent")
      expect(contract_type.to_s).to eq("rent")
    end
  end

  describe "#rent?" do
    it "returns true for rent" do
      contract_type = described_class.new("rent")
      expect(contract_type.rent?).to be true
    end
  end

  describe "#==" do
    it "returns true for equal contract types" do
      type1 = described_class.new("rent")
      type2 = described_class.new("rent")
      expect(type1).to eq(type2)
    end

    it "returns false for different types" do
      type = described_class.new("rent")
      expect(type).not_to eq("rent")
    end
  end
end

