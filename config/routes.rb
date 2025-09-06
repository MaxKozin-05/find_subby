# config/routes.rb - Alternative cleaner approach
Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    get '/dashboard', to: 'dashboard#show', as: :dashboard
    resource :profile, only: [:show, :edit, :update]
    resources :projects
  end

  # Public mini-sites - just use the short route, no namespace needed
  get '/s/:handle', to: 'public/profiles#show', as: :public_profile

  root 'home#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
