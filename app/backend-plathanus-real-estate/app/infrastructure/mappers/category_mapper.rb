# frozen_string_literal: true

module Mappers
  class CategoryMapper
    def self.to_entity(record)
      return nil unless record

      ::Categories::Entities::Category.new(
        id: record.id,
        name: record.name
      )
    end

    def self.to_record(entity, record = nil)
      record ||= ::Persistence::Models::CategoryRecord.new

      record.name = entity.name

      record
    end
  end
end