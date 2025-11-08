# frozen_string_literal: true

module AuthHelpers
  def authenticate_admin(admin)
    token = ::Authentication::Services::JwtService.encode(admin_id: admin.id)
    { "Authorization" => "Bearer #{token}" }
  end

  def admin_headers(admin)
    authenticate_admin(admin)
  end

  def create_authenticated_admin(email: "admin@example.com", password: "password123")
    admin = FactoryBot.create(:admin_record, email: email, password: password)
    { admin: admin, headers: admin_headers(admin) }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end

