# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::Services::PropertyFilterService do
  describe ".build_filters" do
    it "builds filters from params" do
      params = {
        search: "test",
        city: "São Paulo",
        rooms: [2, 3],
        price_min: 1000,
        price_max: 3000,
        furnished: true
      }

      filters = described_class.build_filters(params)

      expect(filters[:search]).to eq("test")
      expect(filters[:city]).to eq("São Paulo")
      expect(filters[:rooms]).to eq([2, 3])
      expect(filters[:price_min]).to eq(1000)
      expect(filters[:price_max]).to eq(3000)
      expect(filters[:furnished]).to be true
    end

    it "handles search with 'q' parameter" do
      params = { q: "test search" }
      filters = described_class.build_filters(params)

      expect(filters[:search]).to eq("test search")
    end

    it "prefers 'search' over 'q'" do
      params = { search: "test", q: "other" }
      filters = described_class.build_filters(params)

      expect(filters[:search]).to eq("test")
    end

    it "handles empty params" do
      filters = described_class.build_filters({})
      expect(filters).to be_a(Hash)
    end

    it "handles nil params" do
      filters = described_class.build_filters(nil)
      expect(filters).to be_a(Hash)
    end
  end

  describe ".build_order" do
    it "returns default order for 'recent'" do
      order = described_class.build_order("recent")
      expect(order).to eq({ created_at: :desc })
    end

    it "returns default order for invalid order" do
      order = described_class.build_order("invalid")
      expect(order).to eq({ created_at: :desc })
    end

    it "handles nil order" do
      order = described_class.build_order(nil)
      expect(order).to eq({ created_at: :desc })
    end
  end
end

