# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mappers::CategoryMapper do
  describe ".to_entity" do
    let(:category_record) { create(:category_record) }

    it "maps record to entity" do
      entity = described_class.to_entity(category_record)

      expect(entity).to be_a(Categories::Entities::Category)
      expect(entity.id).to eq(category_record.id)
      expect(entity.name).to eq(category_record.name)
    end

    it "returns nil for nil record" do
      expect(described_class.to_entity(nil)).to be_nil
    end
  end

  describe ".to_record" do
    let(:category_entity) do
      Categories::Entities::Category.new(id: 1, name: "Apartamento")
    end

    it "maps entity to new record" do
      record = described_class.to_record(category_entity)

      expect(record).to be_a(::Persistence::Models::CategoryRecord)
      expect(record.name).to eq("Apartamento")
    end

    it "maps entity to existing record" do
      existing_record = create(:category_record)
      record = described_class.to_record(category_entity, existing_record)

      expect(record.id).to eq(existing_record.id)
      expect(record.name).to eq("Apartamento")
    end
  end
end

