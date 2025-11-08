# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::UseCases::ShowProperty do
  let(:property_repository) { double("PropertyRepository") }
  let(:use_case) { described_class.new(property_repository) }

  describe "#execute" do
    let(:property) { Properties::Entities::Property.new(id: 1, name: "Test Property") }

    it "returns property when found" do
      allow(property_repository).to receive(:find).with(1).and_return(property)

      result = use_case.execute(1)

      expect(result).to eq(property)
    end

    it "raises error when property not found" do
      allow(property_repository).to receive(:find).with(99999).and_raise(ActiveRecord::RecordNotFound)

      expect {
        use_case.execute(99999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

