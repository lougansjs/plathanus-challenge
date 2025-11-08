hosts = {
  development: { host: ENV.fetch("RAILS_DEFAULT_URL_HOST", "localhost"), port: ENV.fetch("PORT", 3001) },
  test: { host: "example.com", port: nil },
  production: { host: ENV.fetch("RAILS_DEFAULT_URL_HOST", "localhost"), port: nil }
}.freeze

env_config = hosts[Rails.env.to_sym] || { host: "localhost", port: nil }
Rails.application.routes.default_url_options[:host] = env_config[:host]
Rails.application.routes.default_url_options[:port] = env_config[:port] if env_config[:port]
