Rails.application.routes.draw do
  # Swagger documentation
  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      get "auth/verify", to: "auth#verify"

      resources :properties do
        member do
          delete :delete_photo
        end
      end
      resources :categories, only: %i[index]
    end
  end
end
