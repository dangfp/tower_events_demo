Rails.application.routes.draw do
  get 'home/index'

  resources :teams do
    resources :events, only: :index
  end

  resources :projects, only: [:index, :show]

  resources :todos, only: [:show]

  root 'home#index'
end
