Rails.application.routes.draw do
  
  resources :tags, only: [:index, :show]
  resources :images

  root to: 'pages#activity'
  devise_for :users

  get '*path', controller: 'pages', action: 'render_404'
end
