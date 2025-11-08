# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/login" do
    let(:admin) { create(:admin_record, email: "admin@example.com", password: "password123") }

    context "with valid credentials" do
      it "returns a token" do
        post "/api/v1/auth/login", params: { email: admin.email, password: "password123" }

        expect(response).to have_http_status(:ok)
        expect(json_response).to include("token", "message")
        expect(json_response["message"]).to eq("Login realizado com sucesso")
      end

      it "returns a valid JWT token" do
        post "/api/v1/auth/login", params: { email: admin.email, password: "password123" }

        token = json_response["token"]
        decoded = ::Authentication::Services::JwtService.decode(token)
        expect(decoded["admin_id"]).to eq(admin.id)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized with wrong password" do
        post "/api/v1/auth/login", params: { email: admin.email, password: "wrong_password" }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Credenciais inválidas")
      end

      it "returns unauthorized with non-existent email" do
        post "/api/v1/auth/login", params: { email: "nonexistent@example.com", password: "password123" }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Credenciais inválidas")
      end

      it "returns unauthorized with missing email" do
        post "/api/v1/auth/login", params: { password: "password123" }

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized with missing password" do
        post "/api/v1/auth/login", params: { email: admin.email }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/auth/verify" do
    let(:admin) { create(:admin_record) }
    let(:token) { ::Authentication::Services::JwtService.encode(admin_id: admin.id) }

    context "with valid token" do
      it "returns valid true" do
        get "/api/v1/auth/verify", headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        expect(json_response["valid"]).to be true
        expect(json_response["message"]).to be_present
      end
    end

    context "with invalid token" do
      it "returns valid false with invalid token" do
        get "/api/v1/auth/verify", headers: { "Authorization" => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["valid"]).to be false
      end

      it "returns unauthorized without token" do
        get "/api/v1/auth/verify"

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["valid"]).to be false
        expect(json_response["message"]).to eq("Token não fornecido")
      end

      it "returns unauthorized with expired token" do
        expired_token = ::Authentication::Services::JwtService.encode(
          { admin_id: admin.id },
          Time.current - 25.hours
        )

        get "/api/v1/auth/verify", headers: { "Authorization" => "Bearer #{expired_token}" }

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized with token for non-existent admin" do
        non_existent_token = ::Authentication::Services::JwtService.encode(admin_id: 99999)

        get "/api/v1/auth/verify", headers: { "Authorization" => "Bearer #{non_existent_token}" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

