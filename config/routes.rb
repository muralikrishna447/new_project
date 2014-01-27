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
    match '/users/auth/google/callback', to: 'users/omniauth_callbacks#google'
    match '/users/auth/facebook/callback', to: 'users/omniauth_callbacks#facebook'
    match '/users/contacts/google', to: 'users/contacts#google'
    post '/users/contacts/invite', to: 'users/contacts#invite'
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
  get 'egg-timer' => 'pages#egg_timer', as: 'egg_timer'
  get 'sous-vide-collection' => 'pages#sv_collection', as: 'sv_collection'
  get 'test-purchaseable-course' => 'pages#test_purchaseable_course', as: 'test_purchaseable_course'
  match '/mp', to: redirect('/courses/spherification')
  match '/MP', to: redirect('/courses/spherification')
  match '/ps', to: redirect('/courses/accelerated-sous-vide-cooking-course')
  match '/PS', to: redirect('/courses/accelerated-sous-vide-cooking-course')

  resources :quiz_sessions, only: [:create, :update], path: 'quiz-sessions'

  resources :user_profiles, only: [:show, :edit, :update], path: 'profiles'

  # resources :courses, only: [:index, :show] do
  #   resources :activities, only: [:show], path: ''
  #   member do
  #     post 'enroll' => 'courses#enroll'
  #   end
  # end

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
      get 'retake' => 'quizzes#retake'
    end
  end

  resources :equipment, only: [:index, :update, :destroy] do
    member do
      post 'merge' => 'equipment#merge'
    end
  end

  resources :ingredients, only: [:index, :show, :update, :create, :destroy] do
    member do
      post 'merge' => 'ingredients#merge'
      get 'as_json' => 'ingredients#get_as_json'
      resources :comments
    end
    collection do
      get 'all_tags' => 'ingredients#get_all_tags'
      get 'manager' => 'ingredients#manager'
      get 'index_for_gallery' => 'ingredients#index_for_gallery'
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
  match "/gift/:gift_token", to: 'assemblies#redeem'
  match "/gift", to: 'assemblies#redeem_index'

  resources :projects, controller: :assemblies
  resources :streams, only: [:index, :show]
  get 'community-activity' => 'streams#feed', as: 'community_activity'

  resources :sitemaps, :only => :show
  mount Split::Dashboard, at: 'split'
  match "/sitemap.xml", :controller => "sitemaps", :action => "show", :format => :xml
  match "/splitty/finished", :controller => "splitty", :action => "finish_split"

  resources :client_views, only: [:show]
  resources :stream_views, only: [:show]

  resources :charges, only: [:create]

  # Legacy needed b/c the courses version of this URL was public in a few places
  get '/courses/accelerated-sous-vide-cooking-course', to: redirect('/classes/sous-vide-cooking')
  get '/courses/accelerated-sous-vide-cooking-course/:activity_id', to: redirect('/classes/sous-vide-cooking#/%{activity_id}')
  get '/courses/french-macarons/landing', to: redirect('/classes/french-macarons/landing')
  get '/courses/:id', to: redirect('/classes/%{id}/landing')
  get '/courses/:id/:activity_id', to: redirect('/classes/%{id}#/%{activity_id}')

  resources :courses, only: [:index], controller: :courses

  resources :classes, controller: :assemblies do
    member do
      get 'landing', to: 'assemblies#landing'
      get 'show_as_json', to: 'assemblies#show_as_json'
    end
  end

  # Recipe Development Routes
  get '/projects/recipe-development-doughnut-holes/landing', to: redirect('/recipe-developments/doughnut-holes')
  get '/projects/vegetable-demi-glace-recipe-development/landing', to: redirect('/recipe-developments/vegetable-demi-glace')

  resources 'recipe-development', controller: :assemblies, as: :recipe_development, only: [:index, :show]

  resources :events, only: [:create]

  resources :gift_certificates

  get "smoker" => "smoker#index"

  get "/affiliates/share_a_sale" => "affiliates#share_a_sale"

  get "/invitations/welcome" => "home#welcome"

  if Rails.env.angular? || Rails.env.development?
    get "start_clean" => "application#start_clean"
    get "end_clean" => "application#end_clean"
  end

  # http://nils-blum-oeste.net/cors-api-with-oauth2-authentication-using-rails-and-angularjs/
  match '/*path' => 'application#options', :via => :options
end

