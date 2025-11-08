# frozen_string_literal: true

require "rails_helper"

RSpec.describe Authentication::Dto::AuthenticationDto do
  describe "#initialize" do
    it "creates DTO with email and password" do
      dto = described_class.new(email: "admin@example.com", password: "password123")

      expect(dto.email).to eq("admin@example.com")
      expect(dto.password).to eq("password123")
    end

    it "handles missing attributes" do
      dto = described_class.new(email: "admin@example.com")

      expect(dto.email).to eq("admin@example.com")
      expect(dto.password).to be_nil
    end
  end
end

