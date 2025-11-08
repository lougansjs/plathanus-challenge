# frozen_string_literal: true

require "rails_helper"

RSpec.describe Authentication::UseCases::VerifyToken do
  let(:admin_repository) { double("AdminRepository") }
  let(:jwt_service) { double("JwtService") }
  let(:use_case) { described_class.new(admin_repository, jwt_service) }

  describe "#execute" do
    let(:admin) { Authentication::Entities::Admin.new(id: 1, email: "admin@example.com") }

    it "returns valid true when token is valid and admin exists" do
      decoded_token = { admin_id: 1 }
      allow(jwt_service).to receive(:decode).with("valid_token").and_return(decoded_token)
      allow(admin_repository).to receive(:find).with(1).and_return(admin)

      result = use_case.execute("valid_token")

      expect(result[:valid]).to be true
      expect(result[:admin]).to eq(admin)
      expect(result[:message]).to eq("Token válido")
    end

    it "returns valid false when token is invalid" do
      allow(jwt_service).to receive(:decode).with("invalid_token").and_return(nil)

      result = use_case.execute("invalid_token")

      expect(result[:valid]).to be false
      expect(result[:admin]).to be_nil
    end

    it "returns valid false when admin does not exist" do
      decoded_token = { admin_id: 99999 }
      allow(jwt_service).to receive(:decode).with("valid_token").and_return(decoded_token)
      allow(admin_repository).to receive(:find).with(99999).and_return(nil)

      result = use_case.execute("valid_token")

      expect(result[:valid]).to be false
      expect(result[:admin]).to be_nil
    end
  end
end

