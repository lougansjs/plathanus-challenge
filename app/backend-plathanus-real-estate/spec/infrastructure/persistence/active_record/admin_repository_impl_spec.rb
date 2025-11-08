# frozen_string_literal: true

require "rails_helper"

RSpec.describe Persistence::ActiveRecord::AdminRepositoryImpl do
  let(:repository) { described_class.new }

  describe "#find" do
    it "returns admin entity when found" do
      admin_record = create(:admin_record)

      admin = repository.find(admin_record.id)

      expect(admin).to be_a(Authentication::Entities::Admin)
      expect(admin.id).to eq(admin_record.id)
      expect(admin.email).to eq(admin_record.email)
    end

    it "returns nil when not found" do
      admin = repository.find(99999)

      expect(admin).to be_nil
    end
  end

  describe "#find_by_email" do
    it "returns admin entity when found" do
      admin_record = create(:admin_record, email: "admin@example.com")

      admin = repository.find_by_email("admin@example.com")

      expect(admin).to be_a(Authentication::Entities::Admin)
      expect(admin.email).to eq("admin@example.com")
    end

    it "returns nil when not found" do
      admin = repository.find_by_email("nonexistent@example.com")

      expect(admin).to be_nil
    end
  end

  describe "#authenticate" do
    it "returns admin entity with correct credentials" do
      admin_record = create(:admin_record, email: "admin@example.com", password: "password123")

      admin = repository.authenticate("admin@example.com", "password123")

      expect(admin).to be_a(Authentication::Entities::Admin)
      expect(admin.email).to eq("admin@example.com")
    end

    it "returns nil with incorrect password" do
      admin_record = create(:admin_record, email: "admin@example.com", password: "password123")

      admin = repository.authenticate("admin@example.com", "wrong_password")

      expect(admin).to be_nil
    end

    it "returns nil with non-existent email" do
      admin = repository.authenticate("nonexistent@example.com", "password123")

      expect(admin).to be_nil
    end
  end
end

