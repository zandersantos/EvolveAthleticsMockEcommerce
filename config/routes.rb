Rails.application.routes.draw do
  get '/customers/:id/orders', to: 'orders#customer_index', as: 'customer_orders'
  post "/customers/update_province", to: "customers#update_province", as: :update_province
  devise_for :customers
  get '/orders/invoice', to: 'orders#invoice', as: 'order_invoice'
  post '/invoice/submit', to: 'orders#submit_invoice', as: 'submit_invoice'
  get '/order_summary/:id', to: 'orders#summary', as: 'order_summary'
  post "/cart/:id/update_quantity", to: "cart#update_quantity", as: :update_quantity_cart
  get "/orders/create", to: "orders#create", as: "checkout_create"
  get "/orders/success", to: "orders#success", as: "checkout_success"
  get "/orders/cancel", to: "orders#cancel", as: "checkout_cancel"
  get 'search_all', to: 'search#search_all', as: 'search_all'
  resources :pages, except: [ :show ]
  get "/pages/:permalink", to: "pages#permalink", as: "page_permalink"

  resources :cart, only: [:create, :destroy]
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: "home#index"
  resources :orders, only: [:new, :create]
  resources :customers
  resources :products
  resources :categories


  get "up" => "rails/health#show", as: :rails_health_check

end
