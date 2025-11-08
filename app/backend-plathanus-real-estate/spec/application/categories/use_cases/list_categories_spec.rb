# frozen_string_literal: true

require "rails_helper"

RSpec.describe Categories::UseCases::ListCategories do
  let(:category_repository) { double("CategoryRepository") }
  let(:use_case) { described_class.new(category_repository) }

  describe "#execute" do
    let(:categories) do
      [
        Categories::Entities::Category.new(id: 1, name: "Apartamento"),
        Categories::Entities::Category.new(id: 2, name: "Casa")
      ]
    end

    it "returns all categories" do
      allow(category_repository).to receive(:all).and_return(categories)

      result = use_case.execute

      expect(result).to eq(categories)
    end

    it "returns empty array when no categories exist" do
      allow(category_repository).to receive(:all).and_return([])

      result = use_case.execute

      expect(result).to eq([])
    end
  end
end

