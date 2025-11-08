# frozen_string_literal: true

require "rails_helper"

RSpec.describe Categories::Entities::Category do
  describe "#initialize" do
    it "creates a category with all attributes" do
      category = described_class.new(id: 1, name: "Apartamento")

      expect(category.id).to eq(1)
      expect(category.name).to eq("Apartamento")
    end
  end

  describe "#valid?" do
    it "returns true for valid category" do
      category = described_class.new(name: "Apartamento")
      expect(category.valid?).to be true
    end

    it "returns false for blank name" do
      category = described_class.new(name: "")
      expect(category.valid?).to be false
    end

    it "returns false for nil name" do
      category = described_class.new(name: nil)
      expect(category.valid?).to be false
    end
  end
end

