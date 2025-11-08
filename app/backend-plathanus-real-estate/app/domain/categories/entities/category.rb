# frozen_string_literal: true

module Categories
  module Entities
    class Category
      include ActiveModel::Model
      include ActiveModel::Serialization

      attr_accessor :id, :name

      def initialize(id: nil, name: nil)
        @id = id
        @name = name
      end

      def valid?
        name.present?
      end
    end
  end
end