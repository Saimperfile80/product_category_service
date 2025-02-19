Rails.application.routes.draw do
  
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :product_categories
    end
  end

  # Définir la route racine si nécessaire
  # root "home#index"
end
