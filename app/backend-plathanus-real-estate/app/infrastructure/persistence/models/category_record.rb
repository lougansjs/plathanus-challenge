# frozen_string_literal: true

module Persistence
  module Models
    class CategoryRecord < ApplicationRecord
      self.table_name = "categories"

      has_many :properties, class_name: "Persistence::Models::PropertyRecord", foreign_key: "category_id"

      validates :name, presence: true, uniqueness: true
    end
  end
end