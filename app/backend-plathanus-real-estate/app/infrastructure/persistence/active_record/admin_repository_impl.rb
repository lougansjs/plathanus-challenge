# frozen_string_literal: true

module Persistence
  module ActiveRecord
    class AdminRepositoryImpl < Authentication::Repositories::AdminRepository
      def find(id)
        record = ::Persistence::Models::AdminRecord.find_by(id: id)
        ::Mappers::AdminMapper.to_entity(record) if record
      end

      def find_by_email(email)
        record = ::Persistence::Models::AdminRecord.find_by(email: email)
        ::Mappers::AdminMapper.to_entity(record) if record
      end

      def authenticate(email, password)
        record = ::Persistence::Models::AdminRecord.find_by(email: email)
        return nil unless record
        return nil unless record.authenticate(password)

        ::Mappers::AdminMapper.to_entity(record)
      end
    end
  end
end