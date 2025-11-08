# frozen_string_literal: true

module Persistence
  module Models
    class AdminRecord < ApplicationRecord
      self.table_name = "admins"

      has_secure_password

      validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    end
  end
end