# config/routes.rb (updated)
Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    get '/dashboard', to: 'dashboard#show', as: :dashboard
    resource :profile, only: [:show, :edit, :update]
    resources :projects
    resources :jobs, only: [:index, :show, :update, :new, :create]
    resources :notifications, only: [:index, :update] do
      collection do
        patch :mark_all_read
      end
    end

    # Calendar routes
    resources :calendar_days do
      collection do
        post :toggle
        post :bulk_update
      end
    end
  end
  # Public routes
  get '/s/:handle', to: 'public/profiles#show', as: :public_profile
  post '/s/:handle/jobs', to: 'public/jobs#create', as: :public_profile_jobs

  root 'home#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
