# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::UseCases::ListProperties do
  let(:property_repository) { double("PropertyRepository") }
  let(:filter_service) { double("FilterService") }
  let(:use_case) { described_class.new(property_repository, filter_service) }

  describe "#execute" do
    let(:filter_dto) do
      Properties::Dto::PropertyFilterDto.new(
        search: "test",
        page: 1,
        per_page: 10
      )
    end
    let(:property) { Properties::Entities::Property.new(id: 1, name: "Test Property") }
    let(:repository_result) do
      {
        properties: [property],
        meta: { page: 1, per_page: 10, total_pages: 1, total_count: 1 }
      }
    end

    it "returns properties with filters" do
      filters = { search: "test" }
      order = { created_at: :desc }

      allow(filter_service).to receive(:build_filters).and_return(filters)
      allow(filter_service).to receive(:build_order).with("recent").and_return(order)
      allow(property_repository).to receive(:all).with(
        filters: filters,
        order: order,
        page: 1,
        per_page: 10
      ).and_return(repository_result)

      result = use_case.execute(filter_dto)

      expect(result[:properties]).to eq([property])
      expect(result[:meta]).to be_present
    end

    it "uses filter service to build filters" do
      allow(filter_service).to receive(:build_filters).and_return({})
      allow(filter_service).to receive(:build_order).and_return({ created_at: :desc })
      allow(property_repository).to receive(:all).and_return(repository_result)

      use_case.execute(filter_dto)

      expect(filter_service).to have_received(:build_filters)
    end
  end
end

