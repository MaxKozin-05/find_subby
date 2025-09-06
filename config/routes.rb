Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    resource  :profile
    resources :projects
    resource  :dashboard, only: :show
  end

  get '/s/:handle', to: 'public/profiles#show', as: :public_profile

  root 'home#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
