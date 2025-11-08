# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::Dto::PropertyFilterDto do
  describe "#initialize" do
    it "creates DTO with search parameter" do
      dto = described_class.new(search: "test")

      expect(dto.search).to eq("test")
    end

    it "uses 'q' parameter when 'search' is not present" do
      dto = described_class.new(q: "test")

      expect(dto.search).to eq("test")
    end

    it "prefers 'search' over 'q'" do
      dto = described_class.new(search: "test", q: "other")

      expect(dto.search).to eq("test")
    end

    it "sets default values" do
      dto = described_class.new({})

      expect(dto.order).to eq("recent")
      expect(dto.page).to eq(1)
      expect(dto.per_page).to eq(12)
    end

    it "limits per_page to maximum of 100" do
      dto = described_class.new(per_page: 200)

      expect(dto.per_page).to eq(100)
    end

    it "handles all filter parameters" do
      params = {
        search: "test",
        city: "São Paulo",
        rooms: [2, 3],
        price_min: 1000,
        price_max: 3000,
        furnished: true
      }

      dto = described_class.new(params)

      expect(dto.search).to eq("test")
      expect(dto.city).to eq("São Paulo")
      expect(dto.rooms).to eq([2, 3])
      expect(dto.price_min).to eq(1000)
      expect(dto.price_max).to eq(3000)
      expect(dto.furnished).to be true
    end
  end
end

