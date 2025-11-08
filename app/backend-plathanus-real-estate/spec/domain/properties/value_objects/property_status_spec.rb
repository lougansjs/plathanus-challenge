# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::ValueObjects::PropertyStatus do
  describe "#initialize" do
    it "creates a valid status" do
      status = described_class.new("available")
      expect(status.value).to eq("available")
    end

    it "accepts string values" do
      status = described_class.new("unavailable")
      expect(status.value).to eq("unavailable")
    end

    it "raises error for invalid status" do
      expect { described_class.new("invalid") }.to raise_error(ArgumentError, /Invalid status/)
    end

    it "converts symbol to string" do
      status = described_class.new(:available)
      expect(status.value).to eq("available")
    end
  end

  describe "#to_s" do
    it "returns the status as string" do
      status = described_class.new("available")
      expect(status.to_s).to eq("available")
    end
  end

  describe "predicate methods" do
    it "returns true for available?" do
      status = described_class.new("available")
      expect(status.available?).to be true
      expect(status.unavailable?).to be false
    end

    it "returns true for unavailable?" do
      status = described_class.new("unavailable")
      expect(status.unavailable?).to be true
      expect(status.available?).to be false
    end

    it "returns true for rented?" do
      status = described_class.new("rented")
      expect(status.rented?).to be true
    end

    it "returns true for maintenance?" do
      status = described_class.new("maintenance")
      expect(status.maintenance?).to be true
    end

    it "returns true for archived?" do
      status = described_class.new("archived")
      expect(status.archived?).to be true
    end
  end

  describe "#==" do
    it "returns true for equal statuses" do
      status1 = described_class.new("available")
      status2 = described_class.new("available")
      expect(status1).to eq(status2)
    end

    it "returns false for different statuses" do
      status1 = described_class.new("available")
      status2 = described_class.new("unavailable")
      expect(status1).not_to eq(status2)
    end

    it "returns false for different types" do
      status = described_class.new("available")
      expect(status).not_to eq("available")
    end
  end
end

