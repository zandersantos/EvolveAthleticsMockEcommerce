Rails.application.routes.draw do
  resources :pages, except: [ :show ]
  get "/pages/:permalink", to: "pages#permalink", as: "page_permalink"
  resources :cart, only: [:create, :destroy]
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: "home#index"
  resources :orders
  resources :customers
  resources :products
  resources :categories
  scope "/orders" do
    post "create", to: "orders#create", as: "checkout_create"
    get "success", to: "orders#success", as: "checkout_success"
    get "cancel", to: "orders#cancel", as: "checkout_cancel"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
