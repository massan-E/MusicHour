Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  root "static_page#top"
  get "privacy_policy", to: "static_page#privacy_policy"
  get "terms", to: "static_page#terms"
  get "usage", to: "static_page#usage"

  resources :programs do
    resources :letterboxes, only: %i[ index new create edit update destroy ]
    resources :letters, only: %i[ show index new create destroy ], shallow: true do
      post "/read", to: "letter_status#read"
      post "/unread", to: "letter_status#unread"
      patch "/update_star", to: "letter_status#update_star"
    end
    post "letters/check", to: "letters#check", as: :letter_check
    resources :invitations, only: %i[ show new create edit update ]
    resource :random_letters, only: %i[ show ] do
      collection do
        get "random"
        get "reset"
      end
    end
    post "switch_publish", to: "object_publish#switch_publish"
  end

  get "/search", to: "auto_complete#search"

  resources :users, only: %i[ index show destroy ]

  get "up" => "rails/health#show", as: :rails_health_check
end
