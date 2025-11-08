# frozen_string_literal: true

module Authentication
  module Dto
    class AuthenticationDto
      attr_accessor :email, :password

      def initialize(params)
        @email = params[:email]
        @password = params[:password]
      end
    end
  end
end