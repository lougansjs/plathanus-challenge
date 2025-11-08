# frozen_string_literal: true

require "rails_helper"

RSpec.describe Authentication::UseCases::AuthenticateAdmin do
  let(:admin_repository) { double("AdminRepository") }
  let(:jwt_service) { double("JwtService") }
  let(:use_case) { described_class.new(admin_repository, jwt_service) }

  describe "#execute" do
    let(:dto) { Authentication::Dto::AuthenticationDto.new(email: "admin@example.com", password: "password123") }
    let(:admin) { Authentication::Entities::Admin.new(id: 1, email: "admin@example.com") }

    it "returns token and admin when credentials are valid" do
      allow(admin_repository).to receive(:authenticate).with("admin@example.com", "password123").and_return(admin)
      allow(jwt_service).to receive(:encode).with(admin_id: 1).and_return("token123")

      result = use_case.execute(dto)

      expect(result).to include(:token, :admin)
      expect(result[:token]).to eq("token123")
      expect(result[:admin]).to eq(admin)
    end

    it "returns nil when credentials are invalid" do
      invalid_dto = Authentication::Dto::AuthenticationDto.new(email: "admin@example.com", password: "wrong_password")
      allow(admin_repository).to receive(:authenticate).with("admin@example.com", "wrong_password").and_return(nil)

      result = use_case.execute(invalid_dto)

      expect(result).to be_nil
    end

    it "returns nil when admin does not exist" do
      nonexistent_dto = Authentication::Dto::AuthenticationDto.new(email: "nonexistent@example.com", password: "password123")
      allow(admin_repository).to receive(:authenticate).with("nonexistent@example.com", "password123").and_return(nil)

      result = use_case.execute(nonexistent_dto)

      expect(result).to be_nil
    end
  end
end

