Rails.application.routes.draw do
  resources :teams do
    resources :events, only: :index
  end
end
