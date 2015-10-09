require 'resque/server'

Delve::Application.routes.draw do
  get '/robots.txt' => RobotsTxt

  resque_constraint = lambda do |request|
    request.env['warden'].authenticate? and request.env['warden'].user.admin?
  end

  constraints resque_constraint do
    mount Resque::Server.new, :at => "/resque"
  end

  # Redirect non www. to www.
  if Rails.env.production? || Rails.env.staging?
    constraints(host: /^(?!www\.)/i) do
      match "*any", to: redirect(:subdomain => 'www', :path => "/%{any}")
    end
  end

  # Redirect old forum.chefsteps.com to new forum
  constraints :subdomain => "forum" do
    root to: redirect(:subdomain => 'www', :path => "/forum")
    match "*any", to: redirect(:subdomain => 'www', :path => "/forum")
  end

  root to: 'home#new_home'
  match '/old_home', to: 'home#index'
  # Keep the old homepage routes around until we feel we can delete them
  # root to: "home#index"
  # match '/new_home', to: 'home#new_home'
  match '/home_manager', to: 'home#manager'

  match '/forum', to: 'bloom#forum'
  match '/forum/*path', to: 'bloom#forum'
  match "/forum/*path" => redirect("/?goto=%{path}")
  match '/betainvite', to: 'bloom#betainvite'
  match '/content-discussion/:id', to: 'bloom#content_discussion'
  match '/content/:id', to: 'bloom#content'
  match 'whats-for-dinner', to: 'bloom#whats_for_dinner'
  match 'hot', to: 'bloom#hot'

  get '/blog', to: redirect('http://blog.chefsteps.com/')

  resources :featured, only: [:index] do
    collection do
      get 'cover-photo' => 'featured#cover'
    end
  end

  ActiveAdmin.routes(self)

  match '/become', to: 'admin#become'

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

  # Redirect the old sous vide class to 101
  match '/classes/sous-vide-cooking',
    to: redirect('/classes/cooking-sous-vide-getting-started/landing')
  match '/classes/sous-vide-cooking/landing',
    to: redirect('/classes/cooking-sous-vide-getting-started/landing')

  match '/activities/simple-sous-vide-packaging',
    to: redirect('/activities/a-complete-guide-to-sous-vide-packaging-safety-sustainability-and-sourcing')

  # For convenient youtube CTAs
  match '/coffee', to: redirect { |params, request| "/classes/coffee/landing?#{request.params.to_query}" }

  get "styleguide" => "styleguide#index"

  # get 'users/sign_in' => redirect('/#log-in')
  # get 'users/sign_up' => redirect('/#sign-up')
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }

  devise_scope :user do
    get "sign-in", :to => "users/sessions#new"
    get "sign_in", :to => "users/sessions#new"
    get "sign_up", to: 'users/registrations#new'
    get "sign_out", to: 'users/sessions#destroy'
    get "complete_registration", to: 'users/registrations#complete_registration'
    get 'welcome', to: 'users/registrations#welcome'
    match '/users/auth/google/callback', to: 'users/omniauth_callbacks#google'
    match '/users/auth/facebook/callback', to: 'users/omniauth_callbacks#facebook'
    delete '/users/social/disconnect', to: "users/omniauth_callbacks#destroy"
    match '/users/contacts/google', to: 'users/contacts#google'
    post '/users/contacts/invite', to: 'users/contacts#invite'
    post '/users/contacts/gather_friends', to: 'users/contacts#gather_friends'
    post '/users/contacts/email_invite', to: "users/contacts#email_invite"
  end

  get 'users/session_me' => 'users#session_me'
  get 'users/verify' => 'tokens#verify', as: 'verify'
  get 'getUser' => 'users#get_user'
  resources :users, only: [:index, :show] do
    collection do
      get 'cs' => 'users#cs'
    end
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
  get 'kiosk' => 'home#kiosk', as: 'kiosk'
  get 'embeddable_signup' => 'home#embeddable_signup', as: 'embeddable_signup'
  get 'dashboard' => 'dashboard#index', as: 'dashboard'
  get 'ftue' => 'dashboard#ftue', as: 'ftue'
  get 'knife-collection' => 'pages#knife_collection', as: 'knife_collection'
  get 'egg-timer' => 'pages#egg_timer', as: 'egg_timer'
  get 'sous-vide-collection', to: redirect('/sous-vide')
  get 'mobile-about' => 'pages#mobile_about', as: 'mobile_about'
  get 'test-purchaseable-course' => 'pages#test_purchaseable_course', as: 'test_purchaseable_course'
  get 'password-reset-sent' => 'pages#password_reset_sent', as: 'password_reset_sent'
  get 'sous-vide' => 'pages#sous_vide_resources', as: 'sous_vide_resources'
  get 'sous-vide-jobs' => 'pages#sous_vide_jobs', as: 'sous_vide_jobs'
  get 'market' => 'pages#market_ribeye', as: 'market_ribeye'

  # TIMDISCOUNT for the 'tim' part only

  get 'tim' => 'courses#tim'
  match '/mp', to: redirect('/courses/spherification')
  match '/MP', to: redirect('/courses/spherification')
  match '/ps', to: redirect('/courses/accelerated-sous-vide-cooking-course')
  match '/PS', to: redirect('/courses/accelerated-sous-vide-cooking-course')

  resources :user_profiles, only: [:show, :edit, :update], path: 'profiles'

  get '/:ambassador', to: 'courses#index', ambassador: /testambassador|johan|trevor|brendan|matthew|merridith|jack|brian|kyle|timf/

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

  resources :equipment, only: [:index, :update, :destroy] do
    member do
      post 'merge' => 'equipment#merge'
    end
  end

  resources :ingredients, only: [:show, :index, :update, :create, :destroy] do
    member do
      post 'merge' => 'ingredients#merge'
      get 'as_json' => 'ingredients#get_as_json'
      resources :comments
    end
    collection do
      get 'all_tags' => 'ingredients#get_all_tags'
      get 'manager' => 'ingredients#manager'
    end
  end

  get 'gallery/index_as_json' => 'gallery#index_as_json'

  resources :user_activities, only: [:create]
  resources :uploads do
    resources :comments
  end
  resources :users do
    resources :uploads
  end
  resources :likes, only: [:create] do
    collection do
      get 'by_user' => 'likes#by_user'
      post 'unlike' => 'likes#unlike'
    end
  end
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
  resources :comments, only: [:index, :create] do
    collection do
      get 'info' => 'comments#info'
      get 'at' => 'comments#at'
    end
  end
  resources :followerships, only: [:index, :update] do
    post :follow_multiple,  on: :collection
  end
  resources :assemblies, only: [:index, :show] do
    resources :comments
    resources :enrollments
  end
  match "/gift/:gift_token", to: 'assemblies#redeem'
  match "/gift", to: 'assemblies#redeem_index'

  resources :streams, only: [:index, :show]
  get 'community-activity' => 'streams#feed', as: 'community_activity'

  resources :sitemaps, :only => :show
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
  match '/classes', to: 'courses#index'

  resources :classes, controller: :assemblies do
    member do
      get 'landing', to: 'assemblies#landing'
      get 'show_as_json', to: 'assemblies#show_as_json'
    end
  end

  resources :projects, controller: :assemblies do
    member do
      get 'landing', to: 'assemblies#landing'
    end
  end

  # Recipe Development Routes
  get '/projects/recipe-development-doughnut-holes/landing', to: redirect('/recipe-developments/doughnut-holes')
  get '/projects/vegetable-demi-glace-recipe-development/landing', to: redirect('/recipe-developments/vegetable-demi-glace')

  resources 'recipe-development', controller: :assemblies, as: :recipe_development, only: [:index, :show]

  resources :kits, controller: :assemblies, only: [:index, :show] do
    member do
      get 'show_as_json', to: 'assemblies#show_as_json'
    end
  end

  resources :events, only: [:create]

  resources :gift_certificates
  resources :user_surveys, only: [:create]
  resources :recommendations, only: [:index]

  get "smoker" => "smoker#index"

  get "/affiliates/share_a_sale" => "affiliates#share_a_sale"

  get "/invitations/welcome" => "home#welcome"


  match "/reports/stripe" => "reports#stripe"
  resources :reports


  resources :stripe do
    collection do
      get 'current_customer'
    end
  end

  resources :dashboard, only: [:index] do
    collection do
      get 'comments', to: 'dashboard#comments'
    end
  end

  resources :settings, only: [:index]

  resources :playground, only: [:index]

  resources :locations do
    collection do
      get 'autocomplete', to: 'locations#autocomplete'
    end
  end

  resources :passwords, only: [:edit_from_email] do
    get :edit_from_email, on: :collection
  end

  # resources :components, only: [:index]
  match '/components', to: 'components#index'
  match '/components/*path', to: 'components#index'

  namespace :api do
    namespace :v0 do
      match '/authenticate', to: 'auth#authenticate', via: [:post, :options]
      match '/authenticate_facebook', to: 'auth#authenticate_facebook', via: [:post, :options]
      match '/logout', to: 'auth#logout', via: [:post, :options]
      match '/validate', to: 'auth#validate', via: [:get, :options]
      resources :activities, only: [:index, :show] do
        get :likes, on: :member
      end
      resources :components, only: [:index, :show, :create, :update, :destroy]
      resources :ingredients, only: [:index, :show]
      resources :pages, only: [:index, :show, :create, :update]
      resources :passwords, only: [:update] do
        post :send_reset_email, on: :collection
        post :update_from_email, on: :collection
      end
      resources :profiles, only: [:show] do
        get :classes, on: :member
        get :likes, on: :member
        get :photos, on: :member
        get :recipes, on: :member
      end
      resources :recommendations, only: [:index]
      resources :search, only: [:index]
      resources :users, only: [:index, :create, :update] do
        get :me, on: :collection
      end

      resources :circulators, only: [:index, :create, :destroy] do
        get :token, on: :member
      end

      namespace :shopping do
        resources :products do
          # match '/product/:product_id', to: 'shopping#product'
        end
        resources :users do
          post :multipass, on: :collection
          get :multipass, on: :collection
        end
      end

      match '/*path' => 'base#options', :via => :options

      # match 'activities/', to: 'activities#index', via: [:get, :options]
      # match 'activities/:id', to: 'activities#show', as: 'activity', via: [:get, :options]

    end
  end

  if Rails.env.angular? || Rails.env.development?
    get "start_clean" => "application#start_clean"
    get "end_clean" => "application#end_clean"
  end

  # http://nils-blum-oeste.net/cors-api-with-oauth2-authentication-using-rails-and-angularjs/
  match '/*path' => 'application#options', :via => :options

  # show /pages/vegetarian-sous-vide-recipes also as /vegetarian-sous-vide-recipes
  get ':id', to: 'pages#show', constraints: lambda { |r| ! r.url.match(/jasmine/) }

  # http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', to: 'errors#routing', constraints: lambda { |r| ! r.url.match(/jasmine/) }
end
