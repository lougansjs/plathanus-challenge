# frozen_string_literal: true

require "rails_helper"

RSpec.describe Persistence::ActiveRecord::PropertyRepositoryImpl do
  let(:repository) { described_class.new }
  let(:category) { create(:category_record) }

  describe "#find" do
    it "returns property entity when found" do
      property_record = create(:property_record, category: category)

      property = repository.find(property_record.id)

      expect(property).to be_a(Properties::Entities::Property)
      expect(property.id).to eq(property_record.id)
      expect(property.name).to eq(property_record.name)
    end

    it "includes category when present" do
      property_record = create(:property_record, category: category)

      property = repository.find(property_record.id)

      expect(property.category).to be_a(Categories::Entities::Category)
    end

    it "includes address when present" do
      property_record = create(:property_record, :with_address, category: category)

      property = repository.find(property_record.id)

      expect(property.address).to be_a(Properties::Entities::Address)
    end

    it "raises error when not found" do
      expect {
        repository.find(99999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#all" do
    it "returns paginated properties" do
      create_list(:property_record, 15, category: category)

      result = repository.all(page: 1, per_page: 10)

      expect(result[:properties].length).to eq(10)
      expect(result[:meta][:total_count]).to eq(15)
      expect(result[:meta][:total_pages]).to eq(2)
    end

    it "applies filters" do
      create(:property_record, name: "Property 1", category: category)
      create(:property_record, name: "Property 2", category: category)

      result = repository.all(
        filters: { search: "Property 1" },
        page: 1,
        per_page: 10
      )

      expect(result[:properties].length).to eq(1)
      expect(result[:properties].first.name).to eq("Property 1")
    end

    it "filters by city" do
      property1 = create(:property_record, :with_address, category: category)
      property1.address.update(city: "São Paulo")
      property2 = create(:property_record, :with_address, category: category)
      property2.address.update(city: "Rio de Janeiro")

      result = repository.all(
        filters: { city: "São Paulo" },
        page: 1,
        per_page: 10
      )

      expect(result[:properties].length).to eq(1)
      expect(result[:properties].first.address.city).to eq("São Paulo")
    end

    it "filters by price range" do
      create(:property_record, price: 1000, category: category)
      create(:property_record, price: 3000, category: category)

      result = repository.all(
        filters: { price_min: 2000, price_max: 4000 },
        page: 1,
        per_page: 10
      )

      expect(result[:properties].length).to eq(1)
      expect(result[:properties].first.price_value).to eq(3000)
    end

    it "orders by created_at desc by default" do
      property1 = create(:property_record, created_at: 2.days.ago, category: category)
      property2 = create(:property_record, created_at: 1.day.ago, category: category)

      result = repository.all(page: 1, per_page: 10)

      expect(result[:properties].first.id).to eq(property2.id)
    end
  end

  describe "#create" do
    let(:property_entity) do
      Properties::Entities::Property.new(
        name: "New Property",
        status: "available",
        rooms: 2,
        bathrooms: 1,
        area: 100,
        price: 1500,
        contract_type: "rent",
        category_id: category.id
      )
    end

    it "creates a property" do
      property = repository.create(property_entity)

      expect(property).to be_a(Properties::Entities::Property)
      expect(property.id).to be_present
      expect(::Persistence::Models::PropertyRecord.find(property.id)).to be_present
    end

    it "creates property with address" do
      address_entity = Properties::Entities::Address.new(
        street: "Rua Test",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      )
      property_entity.address = address_entity

      property = repository.create(property_entity)

      expect(property.address).to be_present
      expect(property.address.street).to eq("Rua Test")
    end

    it "attaches photos" do
      file = Tempfile.new(["photo", ".jpg"])
      file.write("fake image content")
      file.rewind
      photos = [
        Rack::Test::UploadedFile.new(file.path, "image/jpeg")
      ]

      property = repository.create(property_entity, photos: photos)

      record = ::Persistence::Models::PropertyRecord.find(property.id)
      expect(record.photos.count).to eq(1)
    end
  end

  describe "#update" do
    let(:property_record) { create(:property_record, category: category) }
    let(:property_entity) do
      Properties::Entities::Property.new(
        id: property_record.id,
        name: "Updated Property",
        status: "available",
        rooms: 3,
        bathrooms: 2,
        area: 150,
        price: 2000,
        contract_type: "rent",
        category_id: category.id
      )
    end

    it "updates a property" do
      property = repository.update(property_entity)

      expect(property.name).to eq("Updated Property")
      expect(property.rooms).to eq(3)
      property_record.reload
      expect(property_record.name).to eq("Updated Property")
    end

    it "updates address when present" do
      create(:address_record, property: property_record)
      address_entity = Properties::Entities::Address.new(
        street: "Updated Street",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      )
      property_entity.address = address_entity

      property = repository.update(property_entity)

      property_record.reload
      expect(property_record.address.street).to eq("Updated Street")
    end

    it "creates address if not exists" do
      address_entity = Properties::Entities::Address.new(
        street: "New Street",
        neighborhood: "Centro",
        city: "São Paulo",
        state: "SP",
        country: "Brasil",
        zipcode: "01234-567"
      )
      property_entity.address = address_entity

      property = repository.update(property_entity)

      property_record.reload
      expect(property_record.address).to be_present
      expect(property_record.address.street).to eq("New Street")
    end

    it "attaches new photos" do
      file = Tempfile.new(["photo", ".jpg"])
      file.write("fake image content")
      file.rewind
      photo = Rack::Test::UploadedFile.new(file.path, "image/jpeg")

      property = repository.update(property_entity, photos: [photo])

      property_record.reload
      expect(property_record.photos.count).to eq(1)
    end
  end

  describe "#delete" do
    it "deletes a property" do
      property_record = create(:property_record, category: category)

      repository.delete(property_record.id)

      expect(::Persistence::Models::PropertyRecord.find_by(id: property_record.id)).to be_nil
    end

    it "raises error when not found" do
      expect {
        repository.delete(99999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#delete_photo" do
    it "deletes a photo" do
      property_record = create(:property_record, :with_photos, category: category)
      photo = property_record.photos.first
      signed_id = photo.signed_id

      repository.delete_photo(property_record.id, signed_id)

      property_record.reload
      expect(property_record.photos.count).to eq(2)
    end

    it "raises error when photo not found" do
      property_record = create(:property_record, category: category)

      expect {
        repository.delete_photo(property_record.id, "invalid_signed_id")
      }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
    end
  end
end

