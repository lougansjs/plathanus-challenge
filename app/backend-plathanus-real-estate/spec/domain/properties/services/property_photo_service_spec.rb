# frozen_string_literal: true

require "rails_helper"

RSpec.describe Properties::Services::PropertyPhotoService do
  def create_valid_photo_mock
    photo = double("photo")
    allow(photo).to receive(:content_type).and_return("image/jpeg")
    allow(photo).to receive(:size).and_return(100_000) # 100KB
    allow(photo).to receive(:original_filename).and_return("test.jpg")
    allow(photo).to receive(:read).and_return("\xFF\xD8\xFF\xE0\x00\x10JFIF".b)
    allow(photo).to receive(:pos).and_return(0)
    allow(photo).to receive(:pos=).and_return(0)
    allow(photo).to receive(:rewind).and_return(0)
    photo
  end

  describe ".validate_for_create" do
    it "raises error when photos count is less than minimum" do
      photos = 2.times.map { create_valid_photo_mock }

      expect {
        described_class.validate_for_create(photos)
      }.to raise_error(ArgumentError, /deve ter entre 3 e 5 fotos/)
    end

    it "raises error when photos count is more than maximum" do
      photos = 6.times.map { create_valid_photo_mock }

      expect {
        described_class.validate_for_create(photos)
      }.to raise_error(ArgumentError, /deve ter entre 3 e 5 fotos/)
    end

    it "does not raise error for valid count (3 photos)" do
      photos = 3.times.map { create_valid_photo_mock }

      expect {
        described_class.validate_for_create(photos)
      }.not_to raise_error
    end

    it "does not raise error for valid count (5 photos)" do
      photos = 5.times.map { create_valid_photo_mock }

      expect {
        described_class.validate_for_create(photos)
      }.not_to raise_error
    end

    it "raises error for invalid content type" do
      photo = double("photo")
      allow(photo).to receive(:content_type).and_return("image/gif")
      allow(photo).to receive(:original_filename).and_return("test.gif")
      photos = [photo, create_valid_photo_mock, create_valid_photo_mock]

      expect {
        described_class.validate_for_create(photos)
      }.to raise_error(ArgumentError, /tipo de arquivo inválido/)
    end

    it "raises error for file too large" do
      photo = double("photo")
      allow(photo).to receive(:content_type).and_return("image/jpeg")
      allow(photo).to receive(:size).and_return(11.megabytes)
      allow(photo).to receive(:original_filename).and_return("test.jpg")
      photos = [photo, create_valid_photo_mock, create_valid_photo_mock]

      expect {
        described_class.validate_for_create(photos)
      }.to raise_error(ArgumentError, /arquivo muito grande/)
    end

    it "handles empty array" do
      expect {
        described_class.validate_for_create([])
      }.to raise_error(ArgumentError)
    end

    it "handles nil" do
      expect {
        described_class.validate_for_create(nil)
      }.to raise_error(ArgumentError)
    end
  end

  describe ".validate_for_update" do
    it "raises error when total photos exceed maximum" do
      existing_count = 3
      new_photos = 3.times.map { create_valid_photo_mock }

      expect {
        described_class.validate_for_update(existing_count, new_photos)
      }.to raise_error(ArgumentError, /Não pode exceder/)
    end

    it "does not raise error for valid total count" do
      existing_count = 2
      new_photos = 2.times.map { create_valid_photo_mock }

      expect {
        described_class.validate_for_update(existing_count, new_photos)
      }.not_to raise_error
    end

    it "handles zero existing photos" do
      new_photos = 3.times.map { create_valid_photo_mock }

      expect {
        described_class.validate_for_update(0, new_photos)
      }.not_to raise_error
    end
  end

  describe ".validate_for_delete" do
    it "raises error when remaining count would be less than minimum" do
      remaining_count = 2

      expect {
        described_class.validate_for_delete(remaining_count)
      }.to raise_error(ArgumentError, /deve ter pelo menos 3 fotos/)
    end

    it "does not raise error when remaining count is valid" do
      remaining_count = 3

      expect {
        described_class.validate_for_delete(remaining_count)
      }.not_to raise_error
    end

    it "does not raise error when remaining count is above minimum" do
      remaining_count = 4

      expect {
        described_class.validate_for_delete(remaining_count)
      }.not_to raise_error
    end
  end
end

