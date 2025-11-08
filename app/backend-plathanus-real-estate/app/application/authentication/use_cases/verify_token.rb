# frozen_string_literal: true

module Authentication
  module UseCases
    class VerifyToken
      def initialize(admin_repository, jwt_service)
        @admin_repository = admin_repository
        @jwt_service = jwt_service
      end

      def execute(token)
        decoded = @jwt_service.decode(token)
        return { valid: false, message: "Token inválido ou expirado", admin: nil } unless decoded

        admin = @admin_repository.find(decoded[:admin_id])
        if admin
          { valid: true, message: "Token válido", admin: admin }
        else
          { valid: false, message: "Token inválido ou expirado", admin: nil }
        end
      end
    end
  end
end