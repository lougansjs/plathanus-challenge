# frozen_string_literal: true

module Authentication
  module UseCases
    class AuthenticateAdmin
      def initialize(admin_repository, jwt_service)
        @admin_repository = admin_repository
        @jwt_service = jwt_service
      end

      def execute(dto)
        admin = @admin_repository.authenticate(dto.email, dto.password)
        return nil unless admin

        token = @jwt_service.encode(admin_id: admin.id)
        { token: token, admin: admin }
      end
    end
  end
end