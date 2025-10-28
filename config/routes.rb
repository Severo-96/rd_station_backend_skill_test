require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  resource :cart, only: [:create, :show], controller: 'carts' do
    patch :add_item
    delete ':product_id', to: 'carts#remove_item'
  end

  root "rails/health#show"
end
