Rails.application.routes.draw do
  devise_for :users


  authenticate :user do
    resource :dashboard, only: :show
  end

  root 'home#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
