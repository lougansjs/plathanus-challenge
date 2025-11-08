# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mappers::AdminMapper do
  describe ".to_entity" do
    let(:admin_record) { create(:admin_record) }

    it "maps record to entity" do
      entity = described_class.to_entity(admin_record)

      expect(entity).to be_a(Authentication::Entities::Admin)
      expect(entity.id).to eq(admin_record.id)
      expect(entity.email).to eq(admin_record.email)
    end

    it "returns nil for nil record" do
      expect(described_class.to_entity(nil)).to be_nil
    end
  end

  describe ".to_record" do
    let(:admin_entity) do
      Authentication::Entities::Admin.new(
        email: "admin@example.com",
        password_digest: "hashed_password"
      )
    end

    it "maps entity to new record" do
      record = described_class.to_record(admin_entity)

      expect(record).to be_a(::Persistence::Models::AdminRecord)
      expect(record.email).to eq("admin@example.com")
    end

    it "maps entity to existing record" do
      existing_record = create(:admin_record)
      record = described_class.to_record(admin_entity, existing_record)

      expect(record.id).to eq(existing_record.id)
      expect(record.email).to eq("admin@example.com")
    end

    it "only sets password_digest when present" do
      admin_entity.password_digest = nil
      record = described_class.to_record(admin_entity)

      expect(record.password_digest).to be_nil
    end
  end
end

