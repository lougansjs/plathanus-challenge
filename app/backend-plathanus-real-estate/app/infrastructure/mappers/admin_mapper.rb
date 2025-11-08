# frozen_string_literal: true

module Mappers
  class AdminMapper
    def self.to_entity(record)
      return nil unless record

      ::Authentication::Entities::Admin.new(
        id: record.id,
        email: record.email,
        password_digest: record.password_digest
      )
    end

    def self.to_record(entity, record = nil)
      record ||= ::Persistence::Models::AdminRecord.new

      record.email = entity.email
      record.password_digest = entity.password_digest if entity.password_digest

      record
    end
  end
end