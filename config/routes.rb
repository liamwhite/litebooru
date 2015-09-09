Rails.application.routes.draw do
  
  resources :filters
  resources :notifications
  devise_for :users
  resources :profiles, only: [:show]
  get 'search/index'

  resources :tags, only: [:index, :show]
  resources :images do
    get 'comments'
    put 'update_metadata'
    resources :comments
  end

  namespace :pages do
    get 'activity'
    get 'notifications'
  end

  root to: 'pages#activity'

  get '*path', controller: 'pages', action: 'render_404'
end
