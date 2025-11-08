# frozen_string_literal: true

class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_admin!, only: %i[login verify]
  before_action :initialize_dependencies

  def login
    dto = ::Authentication::Dto::AuthenticationDto.new(auth_params.to_h.symbolize_keys)
    result = @authenticate_admin_use_case.execute(dto)

    if result
      render json: { token: result[:token], message: "Login realizado com sucesso" }, status: :ok
    else
      render json: { error: "Credenciais inválidas" }, status: :unauthorized
    end
  end

  def verify
    token = extract_token_from_header
    return render json: { valid: false, message: "Token não fornecido" }, status: :unauthorized unless token

    result = @verify_token_use_case.execute(token)
    status = result[:valid] ? :ok : :unauthorized

    render json: { valid: result[:valid], message: result[:message] }, status: status
  end

  private

  def initialize_dependencies
    @admin_repository = ::Persistence::ActiveRecord::AdminRepositoryImpl.new
    @jwt_service = ::Authentication::Services::JwtService
    @authenticate_admin_use_case = ::Authentication::UseCases::AuthenticateAdmin.new(@admin_repository, @jwt_service)
    @verify_token_use_case = ::Authentication::UseCases::VerifyToken.new(@admin_repository, @jwt_service)
  end

  def auth_params
    params.permit(:email, :password)
  end
end
