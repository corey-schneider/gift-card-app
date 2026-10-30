Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Gift Cards management
  root "gift_cards#index"
  resources :gift_cards do
    collection do
      get :merchant_suggestions
    end
    member do
      patch :toggle_redeemed
    end
  end

  # Session Unlock / Lock & Passcode setup
  post "unlock", to: "unlocks#create"
  delete "lock", to: "unlocks#destroy"
  post "set_passcode", to: "unlocks#update_passcode"
end
