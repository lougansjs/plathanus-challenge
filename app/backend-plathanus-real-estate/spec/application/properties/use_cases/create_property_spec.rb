# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::UseCases::CreateProperty do
  let(:property_repository) { double("PropertyRepository") }
  let(:property_photo_service) { double("PropertyPhotoService") }
  let(:use_case) { described_class.new(property_repository, property_photo_service) }

  describe "#execute" do
    let(:dto) do
      Properties::Dto::PropertyCreateDto.new(
        name: "New Property",
        status: "available",
        rooms: 2,
        bathrooms: 1,
        area: 100,
        price: 1500,
        contract_type: "rent"
      )
    end
    let(:address_params) do
      {
        street: "Rua Test",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      }
    end
    let(:photos) { [double("photo1"), double("photo2"), double("photo3")] }
    let(:created_property) { Properties::Entities::Property.new(id: 1, name: "New Property") }

    it "creates a property" do
      allow(property_photo_service).to receive(:validate_for_create).with(photos)
      allow(property_repository).to receive(:create).and_return(created_property)

      result = use_case.execute(dto, nil, photos)

      expect(result).to eq(created_property)
      expect(property_photo_service).to have_received(:validate_for_create).with(photos)
    end

    it "creates property with address" do
      property_with_address = Properties::Entities::Property.new(
        id: 1,
        name: "New Property",
        address: Properties::Entities::Address.new(
          street: "Rua Test",
          neighborhood: "Centro",
          city: "São Paulo",
          state: "SP",
          country: "Brasil",
          zipcode: "01234-567"
        )
      )

      allow(property_photo_service).to receive(:validate_for_create).with(photos)
      allow(property_repository).to receive(:create).and_return(property_with_address)

      result = use_case.execute(dto, address_params, photos)

      expect(result).to eq(property_with_address)
      expect(result.address).to be_present
      expect(result.address.street).to eq("Rua Test")
    end

    it "raises error when photo validation fails" do
      allow(property_photo_service).to receive(:validate_for_create).with(photos).and_raise(ArgumentError, "Invalid photos")

      expect {
        use_case.execute(dto, nil, photos)
      }.to raise_error(ArgumentError, "Invalid photos")
    end
  end
end

