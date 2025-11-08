# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::UseCases::DeletePropertyPhoto do
  let(:property_repository) { double("PropertyRepository") }
  let(:property_photo_service) { double("PropertyPhotoService") }
  let(:use_case) { described_class.new(property_repository, property_photo_service) }

  describe "#execute" do
    let(:photos) { [double("photo1"), double("photo2"), double("photo3")] }
    let(:property) do
      Properties::Entities::Property.new(id: 1, photos: photos)
    end

    it "deletes a photo" do
      allow(property_repository).to receive(:find).with(1).and_return(property)
      allow(property_photo_service).to receive(:validate_for_delete).with(2)
      allow(property_repository).to receive(:delete_photo).with(1, "signed_id")

      use_case.execute(1, "signed_id")

      expect(property_photo_service).to have_received(:validate_for_delete).with(2)
      expect(property_repository).to have_received(:delete_photo).with(1, "signed_id")
    end

    it "raises error when remaining photos would be less than minimum" do
      property.photos = [double("photo1"), double("photo2"), double("photo3")]

      allow(property_repository).to receive(:find).with(1).and_return(property)
      allow(property_photo_service).to receive(:validate_for_delete).with(2).and_raise(ArgumentError, "Invalid")

      expect {
        use_case.execute(1, "signed_id")
      }.to raise_error(ArgumentError, "Invalid")
    end

    it "raises error when property not found" do
      allow(property_repository).to receive(:find).with(99999).and_raise(ActiveRecord::RecordNotFound)

      expect {
        use_case.execute(99999, "signed_id")
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

