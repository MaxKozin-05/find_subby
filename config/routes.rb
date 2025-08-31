Rails.application.routes.draw do
  get 'projects/index'
  get 'projects/new'
  get 'projects/create'
  get 'projects/edit'
  get 'projects/update'
  get 'projects/destroy'
  get 'profiles/show'
  get 'profiles/edit'
  get 'profiles/update'
  devise_for :users


  authenticate :user do
    resource :dashboard, only: :show
  end

  root 'home#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
