# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::UseCases::UpdateProperty do
  let(:property_repository) { double("PropertyRepository") }
  let(:property_photo_service) { double("PropertyPhotoService") }
  let(:use_case) { described_class.new(property_repository, property_photo_service) }

  describe "#execute" do
    let(:property) do
      Properties::Entities::Property.new(
        id: 1,
        name: "Old Property",
        status: "available",
        rooms: 2
      )
    end
    let(:dto) do
      Properties::Dto::PropertyCreateDto.new(
        name: "Updated Property",
        status: "unavailable",
        rooms: 3
      )
    end
    let(:updated_property) { Properties::Entities::Property.new(id: 1, name: "Updated Property") }

    it "updates a property" do
      allow(property_repository).to receive(:find).with(1).and_return(property)
      allow(property_repository).to receive(:update).and_return(updated_property)

      result = use_case.execute(1, dto, nil, [])

      expect(result).to eq(updated_property)
      expect(property.name).to eq("Updated Property")
    end

    it "validates photos when new photos are provided" do
      new_photos = [double("photo")]
      allow(property_repository).to receive(:find).with(1).and_return(property)
      allow(property_photo_service).to receive(:validate_for_update).with(0, new_photos)
      allow(property_repository).to receive(:update).and_return(updated_property)

      use_case.execute(1, dto, nil, new_photos)

      expect(property_photo_service).to have_received(:validate_for_update).with(0, new_photos)
    end

    it "updates address when address params are provided" do
      address_params = {
        street: "New Street",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      }
      property.address = Properties::Entities::Address.new(street: "Old Street")

      allow(property_repository).to receive(:find).with(1).and_return(property)
      allow(property_repository).to receive(:update).and_return(updated_property)

      use_case.execute(1, dto, address_params, [])

      expect(property.address.street).to eq("New Street")
    end

    it "creates address when property has no address" do
      address_params = {
        street: "New Street",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      }

      allow(property_repository).to receive(:find).with(1).and_return(property)
      allow(property_repository).to receive(:update).and_return(updated_property)

      use_case.execute(1, dto, address_params, [])

      expect(property.address).to be_present
      expect(property.address.street).to eq("New Street")
    end

    it "raises error when property not found" do
      allow(property_repository).to receive(:find).with(99999).and_raise(ActiveRecord::RecordNotFound)

      expect {
        use_case.execute(99999, dto, nil, [])
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

