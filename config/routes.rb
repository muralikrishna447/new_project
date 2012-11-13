Delve::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  get "styleguide" => "styleguide#index"

  get 'users/sign_in' => redirect('/#log-in')
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
  }

  get 'users/forum-sso' => 'forum_sso_controller#authenticate', as: 'forum_sso'

  root to: "home#index"

  get 'global-navigation' => 'application#global_navigation', as: 'global_navigation'

  post 'subscribe' => "mailing_list#subscribe", as: 'mailing_list_subscribe'

  get 'terms-of-service' => 'home#terms_of_service', as: 'terms_of_service'

  get 'thank-you' => 'thank_you#show', as: 'thank_you'

  resources :user_profiles, only: [:show], path: 'profiles'

  resources :courses, only: [:show]
  resources :activities, only: [:show] do
    member do
      post 'cooked-this' => 'activities#cooked_this', as: 'cooked_this'
      get ':token' => 'activities#show_private', as: 'private'
    end
  end

end

