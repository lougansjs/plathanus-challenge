class ApplicationController < ActionController::API
  include ApiVersioning

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request

  before_action :authenticate_admin!, if: :admin_route?

  private

  def admin_route?
    request.path.start_with?("/api/v1/properties") &&
      %w[create update destroy delete_photo].include?(action_name)
  end

  def authenticate_admin!
    token = extract_token_from_header
    return render_unauthorized unless token

    result = verify_token_use_case.execute(token)
    return render_unauthorized unless result[:valid]

    @current_admin = result[:admin]
    render_unauthorized unless @current_admin
  end

  def extract_token_from_header
    auth_header = request.headers["Authorization"]
    return nil unless auth_header

    auth_header.split(" ").last if auth_header.start_with?("Bearer ")
  end

  def render_unauthorized
    render json: { error: "Não autorizado" }, status: :unauthorized
  end

  def admin_repository
    @admin_repository ||= ::Persistence::ActiveRecord::AdminRepositoryImpl.new
  end

  def jwt_service
    ::Authentication::Services::JwtService
  end

  def verify_token_use_case
    @verify_token_use_case ||= ::Authentication::UseCases::VerifyToken.new(admin_repository, jwt_service)
  end

  def not_found(exception)
    render json: { error: "not_found", message: exception.message },
           status: :not_found
  end

  def unprocessable_entity(exception)
    render json: {
      error: "validation_error",
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def bad_request(exception)
    render json: { error: "bad_request", message: exception.message },
           status: :bad_request
  end

  def internal_server_error(exception)
    Rails.logger.error "#{exception.class}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    render json: { error: "internal_server_error" },
           status: :internal_server_error
  end
end
