Rails.application.routes.draw do
  
  devise_for :users
  resources :filters
  resources :notifications
  resources :profiles, only: [:show]
  resources :reports, only: [:index, :new, :create]

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

  get '/comments', action: :index, controller: :comments

  root to: 'pages#activity'
  get '*path', controller: 'pages', action: 'render_404'
end
