Delve::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  get "styleguide" => "styleguide#index"

  # get 'users/sign_in' => redirect('/#log-in')
  # get 'users/sign_up' => redirect('/#sign-up')
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
  }

  get 'authenticate-sso' => 'sso#index', as: 'forum_sso'

  root to: "home#index"

  get 'global-navigation' => 'application#global_navigation', as: 'global_navigation'

  get 'thank-you' => 'copy#thank_you', as: 'thank_you'
  get 'thank-you-subscribing' => 'copy#thank_you_subscribing', as: 'thank_you_subscribing'
  get 'legal' => 'copy#legal', as: 'legal'
  get 'legal/:type' => 'copy#legal', as: 'legal_type'
  get 'legal/terms' => 'copy#legal', as: 'terms_of_service'
  get 'legal/privacy' => 'copy#legal', as: 'privacy'
  get 'legal/licensing' => 'copy#legal', as: 'licensing'
  get 'about' => 'home#about', as: 'about'

  resources :quiz_sessions, only: [:create, :update], path: 'quiz-sessions'

  resources :user_profiles, only: [:show, :update], path: 'profiles'

  resources :courses, only: [:show] do
    resources :activities, only: [:show], path: ''
  end

  # Allow top level access to an activity even if it isn't in a course
  # This will also be the rel=canonical version
  resources :activities, only: [:show] do
    member do
      post 'cooked-this' => 'activities#cooked_this', as: 'cooked_this'
    end
  end

  resources :questions, only: [] do
    resources :answers, only: [:create]
  end

  resources :quizzes, only: [:show] do
    member do
      post 'start' => 'quizzes#start'
      post 'finish' => 'quizzes#finish'
      get 'results' => 'quizzes#results'
    end
  end

  resources :search, only: [:index]
end

