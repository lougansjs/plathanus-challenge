# frozen_string_literal: true

require "rails_helper"

RSpec.describe Authentication::Services::JwtService do
  before do
    allow(ENV).to receive(:fetch).with("JWT_SECRET_KEY").and_return("test_secret_key")
  end

  describe ".encode" do
    it "encodes a payload into a JWT token" do
      payload = { admin_id: 1 }
      token = described_class.encode(payload)

      expect(token).to be_a(String)
      expect(token.split(".").length).to eq(3) # JWT has 3 parts
    end

    it "includes expiration time" do
      payload = { admin_id: 1 }
      token = described_class.encode(payload)
      decoded = described_class.decode(token)

      expect(decoded["exp"]).to be_present
      expect(decoded["exp"]).to be > Time.current.to_i
    end

    it "uses custom expiration time" do
      payload = { admin_id: 1 }
      exp = 1.hour.from_now
      token = described_class.encode(payload, exp)
      decoded = described_class.decode(token)

      expect(decoded["exp"]).to eq(exp.to_i)
    end
  end

  describe ".decode" do
    it "decodes a valid JWT token" do
      payload = { admin_id: 1 }
      token = described_class.encode(payload)

      decoded = described_class.decode(token)

      expect(decoded["admin_id"]).to eq(1)
    end

    it "returns nil for invalid token" do
      result = described_class.decode("invalid_token")
      expect(result).to be_nil
    end

    it "returns nil for expired token" do
      payload = { admin_id: 1 }
      token = described_class.encode(payload, Time.current - 1.hour)

      result = described_class.decode(token)
      expect(result).to be_nil
    end

    it "returns nil for token with wrong secret" do
      payload = { admin_id: 1 }
      token = JWT.encode(payload, "wrong_secret", "HS256")

      result = described_class.decode(token)
      expect(result).to be_nil
    end
  end
end

