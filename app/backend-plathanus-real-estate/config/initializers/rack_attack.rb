# frozen_string_literal: true

# Rack::Attack configuration for rate limiting and security
class Rack::Attack
  # Throttle login attempts (5 attempts per 20 minutes per IP)
  throttle("logins/ip", limit: 5, period: 20.minutes) do |req|
    if req.path == "/api/v1/auth/login" && req.post?
      req.ip
    end
  end
end
