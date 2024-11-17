Rails.application.routes.draw do
  root "static_page#top"

  get    "/login",   to: "user_sessions#new"
  post   "/login",   to: "user_sessions#create"
  delete "/logout",  to: "user_sessions#destroy"

  resources :letterboxes do
    resources :letters, shallow: true
  end
  resources :users
  resources :programs

  get "up" => "rails/health#show", as: :rails_health_check
end
