Delve::Application.routes.draw do
  root to: "home#index"

  ActiveAdmin.routes(self)

  # Redirects
  match '/courses/accelerated-sous-vide-cooking-course/improvised-sous-vide-cooking-running-water-method',
    to: redirect('/courses/accelerated-sous-vide-cooking-course/improvised-sous-vide-running-water-method')
  match '/activities/improvised-sous-vide-cooking-running-water-method',
    to: redirect('/activities/improvised-sous-vide-running-water-method')

  match '/courses/accelerated-sous-vide-cooking-course/improvised-sous-vide-cooking-insulated-cooler-method',
    to: redirect('/courses/accelerated-sous-vide-cooking-course/improvised-sous-vide-insulated-cooler-method')
  match '/activities/improvised-sous-vide-cooking-insulated-cooler-method',
    to: redirect('/activities/improvised-sous-vide-insulated-cooler-method')

  match '/courses/accelerated-sous-vide-cooking-course/sous-vide-pork-cheek-with-celery-root-and-pickled-apples',
    to: redirect('/courses/accelerated-sous-vide-cooking-course/sous-vide-pork-cheek-celery-root-pickled-apples')
  match '/activities/sous-vide-pork-cheek-with-celery-root-and-pickled-apples',
    to: redirect('/activities/sous-vide-pork-cheek-celery-root-pickled-apples')


  get "styleguide" => "styleguide#index"

  # get 'users/sign_in' => redirect('/#log-in')
  # get 'users/sign_up' => redirect('/#sign-up')
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }

  devise_scope :user do
    get "sign_in", :to => "users/sessions#new"
    get "sign_up", to: 'users/registrations#new'
    get "sign_out", to: 'users/sessions#destroy'
    get "complete_registration", to: 'users/registrations#complete_registration'
    get 'welcome', to: 'users/registrations#welcome'
    post 'signup_and_enroll', to: 'users/registrations#signup_and_enroll'
    post 'signin_and_enroll', to: 'users/sessions#signin_and_enroll'
  end

  get 'authenticate-sso' => 'sso#index', as: 'forum_sso'

  get 'global-navigation' => 'application#global_navigation', as: 'global_navigation'

  get 'thank-you' => 'copy#thank_you', as: 'thank_you'
  get 'thank-you-subscribing' => 'copy#thank_you_subscribing', as: 'thank_you_subscribing'
  get 'legal' => 'copy#legal', as: 'legal'
  get 'legal/:type' => 'copy#legal', as: 'legal_type'
  get 'legal/terms' => 'copy#legal', as: 'terms_of_service'
  get 'legal/privacy' => 'copy#legal', as: 'privacy'
  get 'legal/licensing' => 'copy#legal', as: 'licensing'
  get 'jobs' => 'copy#jobs', as: "jobs"
  get 'about' => 'home#about', as: 'about'
  get 'discussion' => 'forum#discussion', as: 'discussion'
  get 'dashboard' => 'dashboard#index', as: 'dashboard'
  get 'knife-collection' => 'pages#knife_collection', as: 'knife_collection'
  match '/mp', to: redirect('/courses/spherification')

  resources :quiz_sessions, only: [:create, :update], path: 'quiz-sessions'

  resources :user_profiles, only: [:show, :edit, :update], path: 'profiles'

  resources :courses, only: [:index, :show] do
    resources :activities, only: [:show], path: ''
    member do
      post 'enroll' => 'courses#enroll'
    end
  end

  # Allow top level access to an activity even if it isn't in a course
  # This will also be the rel=canonical version
  resources :activities, only: [:show, :new] do
    member do
      # Kind of ugly but explicit - since we still get the show view as HTML,
      # and requesting it as JSON too was screwing up browser history
      get 'as_json' => 'activities#get_as_json'
      put 'as_json' => 'activities#update_as_json'
      get 'fork' => 'activities#fork'
      put 'notify_start_edit' => 'activities#notify_start_edit'
      put 'notify_end_edit' => 'activities#notify_end_edit'
    end
    collection do
      get 'all_tags' => 'activities#get_all_tags'
    end
  end

  match '/base_feed' => 'activities#base_feed', as: :base_feed, :defaults => { :format => 'atom' }
  match '/feed' => 'activities#feedburner_feed', as: :feed

  resources :questions, only: [] do
    resources :answers, only: [:create]
  end

  # This is to work around a bug in ActiveAdmin 0.6.0 where the :shallow designator in questions.rb
  # stopped working
  namespace :admin do
    resources :questions
  end

  resources :quizzes, only: [:show] do
    member do
      post 'start' => 'quizzes#start'
      post 'finish' => 'quizzes#finish'
      get 'results' => 'quizzes#results'
    end
  end

  resources :equipment, only: [:index]
  resources :ingredients, only: [:index, :update, :destroy] do
    member do
      post 'merge' => 'ingredients#merge'
    end
  end

  resources :gallery, only: [:index], path: 'gallery' do
    collection do
      get 'index_as_json' => 'gallery#index_as_json'
    end
  end
  resources :user_activities, only: [:create]
  resources :uploads do
    resources :comments
  end
  resources :users do
    resources :uploads
  end
  resources :likes, only: [:create]
  resources :pages, only: [:show]
  resources :badges, only: [:index]
  resources :polls do
    member do
      get 'show_as_json' => 'polls#show_as_json'
    end
  end
  resources :poll_items do
    resources :comments
  end
  resources :votes, only: [:create]
  resources :comments
  resources :followerships, only: [:update]
  resources :assemblies, only: [:index, :show] do
    resources :comments
    resources :enrollments
  end
  resources :projects, controller: :assemblies
  resources :streams, only: [:index, :show]
  get 'community-activity' => 'streams#feed', as: 'community_activity'

  resources :sitemaps, :only => :show
  mount Split::Dashboard, at: 'split'
  match "/sitemap.xml", :controller => "sitemaps", :action => "show", :format => :xml
  match "/splitty/finished", :controller => "splitty", :action => "finish_split"

  resources :client_views, only: [:show]
  resources :stream_views, only: [:show]

end

