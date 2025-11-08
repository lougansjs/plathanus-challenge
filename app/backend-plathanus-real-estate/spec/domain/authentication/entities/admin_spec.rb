# frozen_string_literal: true

require "rails_helper"

RSpec.describe Authentication::Entities::Admin do
  describe "#initialize" do
    it "creates an admin with all attributes" do
      admin = described_class.new(
        id: 1,
        email: "admin@example.com",
        password_digest: "hashed_password"
      )

      expect(admin.id).to eq(1)
      expect(admin.email).to eq("admin@example.com")
      expect(admin.password_digest).to eq("hashed_password")
    end
  end

  describe "#valid?" do
    it "returns true for valid email" do
      admin = described_class.new(email: "admin@example.com")
      expect(admin.valid?).to be true
    end

    it "returns false for invalid email" do
      admin = described_class.new(email: "invalid_email")
      expect(admin.valid?).to be false
    end

    it "returns false for blank email" do
      admin = described_class.new(email: "")
      expect(admin.valid?).to be false
    end

    it "returns false for nil email" do
      admin = described_class.new(email: nil)
      expect(admin.valid?).to be false
    end
  end
end

