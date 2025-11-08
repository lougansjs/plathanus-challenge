# frozen_string_literal: true

Rails.application.config.to_prepare do
  unless defined?(Property)
    Property = Persistence::Models::PropertyRecord
  end
end

