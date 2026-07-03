Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "vacation_requests#index"

  resource :session, only: [:new, :create, :destroy]
  get "login" => "sessions#new", as: :login
  delete "logout" => "sessions#destroy", as: :logout

  resources :users, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :vacation_requests do
    resources :decisions, only: [:create]   # HR/head click Approve/Reject here
  end

  resource :settings, only: [:edit, :update]   # boss sets max concurrent vacationers
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
