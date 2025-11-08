# frozen_string_literal: true

module Authentication
  module Repositories
    class AdminRepository
      def find(id)
        raise NotImplementedError, "Subclasses must implement #find"
      end

      def find_by_email(email)
        raise NotImplementedError, "Subclasses must implement #find_by_email"
      end

      def authenticate(email, password)
        raise NotImplementedError, "Subclasses must implement #authenticate"
      end
    end
  end
end