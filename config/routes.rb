Rails.application.routes.draw do
  
  resources :tags, only: [:index, :show]
  resources :images do
    get 'tags'
  end

  root to: 'pages#activity'
  devise_for :users

  get '*path', controller: 'pages', action: 'render_404'
end
