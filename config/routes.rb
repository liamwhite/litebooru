Rails.application.routes.draw do
  
  resources :profiles, only: [:show]
  get 'search/index'

  resources :tags, only: [:index, :show]
  resources :images do
    get 'tags_source'
    get 'comments'
    put 'update_metadata'
    resources :comments
  end

  namespace :pages do
    get 'activity'
    get 'notifications'
  end

  root to: 'pages#activity'
  devise_for :users

  get '*path', controller: 'pages', action: 'render_404'
end
