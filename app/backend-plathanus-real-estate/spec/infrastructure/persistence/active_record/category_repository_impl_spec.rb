# frozen_string_literal: true

require "rails_helper"

RSpec.describe Persistence::ActiveRecord::CategoryRepositoryImpl do
  let(:repository) { described_class.new }

  describe "#find" do
    it "returns category entity when found" do
      category_record = create(:category_record, name: "Apartamento")

      category = repository.find(category_record.id)

      expect(category).to be_a(Categories::Entities::Category)
      expect(category.id).to eq(category_record.id)
      expect(category.name).to eq("Apartamento")
    end

    it "raises error when not found" do
      expect {
        repository.find(99999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#all" do
    it "returns all categories ordered by name" do
      create(:category_record, name: "Casa")
      create(:category_record, name: "Apartamento")
      create(:category_record, name: "Terreno")

      categories = repository.all

      expect(categories.length).to eq(3)
      expect(categories.map(&:name)).to eq(["Apartamento", "Casa", "Terreno"])
    end

    it "returns empty array when no categories exist" do
      categories = repository.all

      expect(categories).to eq([])
    end

    it "returns category entities" do
      create(:category_record)

      categories = repository.all

      expect(categories.first).to be_a(Categories::Entities::Category)
    end
  end
end

