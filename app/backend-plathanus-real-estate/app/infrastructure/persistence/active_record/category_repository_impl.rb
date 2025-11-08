# frozen_string_literal: true

module Persistence
  module ActiveRecord
    class CategoryRepositoryImpl < Categories::Repositories::CategoryRepository
      def find(id)
        record = ::Persistence::Models::CategoryRecord.find(id)
        ::Mappers::CategoryMapper.to_entity(record)
      end

      def all
        ::Persistence::Models::CategoryRecord
          .order(:name)
          .map { |record| ::Mappers::CategoryMapper.to_entity(record) }
      end
    end
  end
end