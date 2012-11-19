Delve::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  get "styleguide" => "styleguide#index"

  get 'users/sign_in' => redirect('/#log-in')
  get 'users/sign_up' => redirect('/#sign-up')
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
  }

  get 'authenticate-sso' => 'sso#index', as: 'forum_sso'

  root to: "home#index"

  get 'global-navigation' => 'application#global_navigation', as: 'global_navigation'

  post 'subscribe' => "mailing_list#subscribe", as: 'mailing_list_subscribe'

  get 'thank-you' => 'copy#thank_you', as: 'thank_you'
  get 'legal' => 'copy#legal', as: 'legal'
  get 'legal/:type' => 'copy#legal', as: 'legal_type'
  get 'legal/terms' => 'copy#legal', as: 'terms_of_service'
  get 'legal/privacy' => 'copy#legal', as: 'privacy'
  get 'legal/licensing' => 'copy#legal', as: 'licensing'

  resources :user_profiles, only: [:show, :update], path: 'profiles'

  resources :courses, only: [:show]
  resources :activities, only: [:show] do
    member do
      post 'cooked-this' => 'activities#cooked_this', as: 'cooked_this'
      get ':token' => 'activities#show', as: 'private'
    end
  end

end

