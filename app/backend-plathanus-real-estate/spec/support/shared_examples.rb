# frozen_string_literal: true

RSpec.shared_examples "requires authentication" do |action, method = :get|
  context "when not authenticated" do
    it "returns unauthorized" do
      send(method, action)
      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]).to eq("Não autorizado")
    end
  end
end

RSpec.shared_examples "paginated response" do
  it "returns pagination metadata" do
    expect(json_response_symbolized[:meta]).to include(
      :page,
      :per_page,
      :total_pages,
      :total_count
    )
  end
end

