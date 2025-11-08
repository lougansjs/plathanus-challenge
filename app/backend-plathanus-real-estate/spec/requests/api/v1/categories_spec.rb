# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Categories", type: :request do
  describe "GET /api/v1/categories" do
    let!(:category1) { create(:category_record, name: "Apartamento") }
    let!(:category2) { create(:category_record, name: "Casa") }

    it "returns all categories" do
      get "/api/v1/categories"

      expect(response).to have_http_status(:ok)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |c| c["name"] }).to contain_exactly("Apartamento", "Casa")
    end

    it "uses cache" do
      expect(Rails.cache).to receive(:fetch).with("categories/all", expires_in: 1.hour).and_call_original

      get "/api/v1/categories"
      expect(response).to have_http_status(:ok)
    end

    it "returns empty array when no categories exist" do
      ::Persistence::Models::CategoryRecord.delete_all

      get "/api/v1/categories"

      expect(response).to have_http_status(:ok)
      expect(json_response).to eq([])
    end

    it "includes API version header" do
      get "/api/v1/categories"

      expect(response.headers["API-Version"]).to eq("1.0.0")
    end
  end
end

