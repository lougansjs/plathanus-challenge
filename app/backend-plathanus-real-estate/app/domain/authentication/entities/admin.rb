# frozen_string_literal: true

module Authentication
  module Entities
    class Admin
      attr_accessor :id, :email, :password_digest

      def initialize(id: nil, email: nil, password_digest: nil)
        @id = id
        @email = email
        @password_digest = password_digest
      end

      def valid?
        email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
      end
    end
  end
end

