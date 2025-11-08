# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::UseCases::DeleteProperty do
  let(:property_repository) { double("PropertyRepository") }
  let(:use_case) { described_class.new(property_repository) }

  describe "#execute" do
    it "deletes a property" do
      allow(property_repository).to receive(:delete).with(1)

      use_case.execute(1)

      expect(property_repository).to have_received(:delete).with(1)
    end

    it "raises error when property not found" do
      allow(property_repository).to receive(:delete).with(99999).and_raise(ActiveRecord::RecordNotFound)

      expect {
        use_case.execute(99999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

