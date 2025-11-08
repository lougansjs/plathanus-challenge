# frozen_string_literal: true

module Persistence
  module Models
    class PropertyRecord < ApplicationRecord
      self.table_name = "properties"

      belongs_to :category, class_name: "Persistence::Models::CategoryRecord", foreign_key: "category_id"
      has_one :address, class_name: "Persistence::Models::AddressRecord", foreign_key: "property_id", dependent: :destroy
      has_many_attached :photos

      # Sobrescreve o polymorphic_name para compatibilidade com registros antigos do ActiveStorage
      def self.polymorphic_name
        "Property"
      end

      # Apenas validações de banco de dados básicas
      validates :name, presence: true, length: { maximum: 255 }
      validates :description, length: { maximum: 5000 }, allow_blank: true
      validates :code, length: { maximum: 50 }, allow_blank: true
      validates :status, :rooms, :bathrooms, :area, :contract_type, presence: true
      validates :rooms, :bathrooms, :area, :parking_slots, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }
      validates :price, :promotional_price, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }
    end
  end
end