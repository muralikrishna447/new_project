require 'resque/server'

Delve::Application.routes.draw do

  # Resque
  resque_constraint = lambda do |request|
    request.env['warden'].authenticate? and request.env['warden'].user.admin?
  end

  constraints resque_constraint do
    mount Resque::Server.new, :at => "/resque"
  end

  # Redirect old forum.chefsteps.com to new forum
  constraints :subdomain => "forum" do
    root to: redirect(:subdomain => 'www', :path => "/forum")
    match "*any", to: redirect(:subdomain => 'www', :path => "/forum")
  end

  # One-off routes
  root to: 'home#new_home'
  get '/robots.txt' => RobotsTxt

  match '/libraries', to: 'legal#libraries'
  match '/joule/warranty', to: 'home#joule_warranty'
  match '/facebook_optout', to: 'home#facebook_optout'

  match '/forum', to: 'bloom#forum'
  match '/forum/*path', to: 'bloom#forum'
  match "/forum/*path" => redirect("/?goto=%{path}")
  match '/betainvite', to: 'bloom#betainvite'
  match '/content-discussion/:id', to: 'bloom#content_discussion'
  match '/content/:id', to: 'bloom#content'

  post '/admin/slack_display', to:'admin#slack_display'

  get '/blog', to: redirect('http://blog.chefsteps.com/')
  get '/presskit', to: redirect('/press')
  get '/jouleapp', to: redirect('/getting-started-with-joule')
  get '/jewel', to: redirect('/joule')
  get '/Joule', to: redirect('/joule')

  # Legal Documents
  get 'eula-ios' => 'legal#eula_ios', as: 'eula_ios'
  get 'eula-android' => 'legal#eula_android', as: 'eula_android'
  get 'privacy' => 'legal#privacy_policy', as: 'privacy'
  get 'privacy-staging' => 'legal#privacy_policy_staging', as: 'privacy_staging'
  get 'terms' => 'legal#terms', as: 'terms'
  get 'terms' => 'legal#terms', as: 'terms_of_service'

  ActiveAdmin.routes(self)

  # For convenient youtube CTAs
  match '/coffee', to: redirect { |params, request| "/classes/coffee/landing?#{request.params.to_query}" }

  # Devise / auth
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
    post '/users/delete_geo_cookie', to: 'users#delete_geo_cookie'
  end

  get 'users/session_me' => 'users#session_me'
  get 'users/preauth' => 'users#preauth'
  get 'users/verify' => 'tokens#verify', as: 'verify'
  match 'users/set_location' => 'users#set_location'

  get 'getUser' => 'users#get_user'
  resources :users, only: [:index, :show] do
    collection do
      get 'cs' => 'users#cs'
    end
  end

  get 'authenticate-sso' => 'sso#index', as: 'forum_sso'

  get 'embeddable_signup' => 'home#embeddable_signup', as: 'embeddable_signup'
  get 'knife-collection' => 'pages#knife_collection', as: 'knife_collection'
  get 'sous-vide-collection', to: redirect('/sous-vide')
  get 'mobile-about' => 'pages#mobile_about', as: 'mobile_about'
  get 'market' => 'pages#market_ribeye', as: 'market_ribeye'
  get 'joule-crawler' => 'pages#joule_crawler', as: 'joule_crawler'

  match '/mp', to: redirect('/classes/spherification')
  match '/MP', to: redirect('/classes/spherification')

  resources :user_profiles, only: [:show, :edit, :update], path: 'profiles'

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

  resources :equipment, only: [:index, :update, :destroy] do
    member do
      post 'merge' => 'equipment#merge'
    end
  end

  resources :ingredients, only: [:show, :index, :update, :create, :destroy] do
    member do
      post 'merge' => 'ingredients#merge'
      get 'as_json' => 'ingredients#get_as_json'
    end
    collection do
      get 'all_tags' => 'ingredients#get_all_tags'
      get 'manager' => 'ingredients#manager'
    end
  end

  get 'gallery/index_as_json' => 'gallery#index_as_json'
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

  resources :assemblies, only: [:index, :show] do
    resources :comments
    member do
      post 'enroll' => 'assemblies#enroll'
    end
  end

  resources :streams, only: [:index, :show]
  get 'community-activity' => 'streams#feed', as: 'community_activity'

  resources :sitemaps, :only => :show
  match "/sitemap.xml", :controller => "sitemaps", :action => "show", :format => :xml

  resources :client_views, only: [:show]
  resources :stream_views, only: [:show]

  resources :classes, controller: :assemblies do
    member do
      get 'landing', to: 'assemblies#landing'
      get 'show_as_json', to: 'assemblies#show_as_json'
    end
  end

  resources :kits, controller: :assemblies, only: [:index, :show] do
    member do
      get 'show_as_json', to: 'assemblies#show_as_json'
    end
  end

  resources :events, only: [:create]

  resources :user_surveys, only: [:create]

  get "/affiliates/share_a_sale" => "affiliates#share_a_sale"

  get "/invitations/welcome" => "home#welcome"

  match "/reports/stripe" => "reports#stripe"
  resources :reports


  resources :stripe do
    collection do
      get 'current_customer'
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

  resources :stripe_webhooks, only: [:create]

  # resources :components, only: [:index]
  match '/components', to: 'components#index'
  match '/components/*path', to: 'components#index'

  get "/tf2" => "tf2_redemptions#index"
  get "/tf2/redemptions" => "tf2_redemptions#show"
  post "/tf2/redemptions" => "tf2_redemptions#create"

  namespace :api do
    namespace :admin do
      resources :users, only: [:show, :index] do
        get :actor_addresses, on: :member
        get :circulators, on: :member
      end
    end

    namespace :v0 do
      match '/authenticate', to: 'auth#authenticate', via: [:post, :options]
      match '/upgrade_token', to: 'auth#upgrade_token', via: [:post, :options]
      match '/authenticate_facebook', to: 'auth#authenticate_facebook', via: [:post, :options]
      match '/logout', to: 'auth#logout', via: [:post, :options]
      match '/validate', to: 'auth#validate', via: [:get, :post, :options]
      resources :activities, only: [:index, :show] do
        get :likes, on: :member
      end
      resources :components, only: [:index, :show, :create, :update, :destroy]
      resources :ingredients, only: [:index, :show]
      resources :likes, only: [:create, :destroy] do
        post :unlike, on: :collection
      end
      resources :locations, only: [:index]
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
      resources :push_notification_tokens, only: [:create, :destroy]
      resources :recommendations, only: [:index]
      resources :search, only: [:index]
      resources :users, only: [:index, :create, :update] do
        get :me, on: :collection
        get :capabilities, on: :collection
        get :shown_terms, on: :collection
        post :international_joule, on: :collection
        get :log_upload_url, on: :collection
      end

      resources :circulators, only: [:index, :create, :update, :destroy] do
        get :token, on: :member
        post :notify_clients, on: :member
        post :admin_notify_clients, on: :member
        post :coefficients, on: :collection
      end

      post 'users/make_premium', to: 'users#make_premium'

      post 'firmware/updates', to: 'firmware#updates'
      get 'auth/external_redirect', to: 'auth#external_redirect'
      get 'auth/external_redirect_by_key', to: 'auth#external_redirect_by_key'

      get 'content_config/manifest', to: 'content#manifest'
      get 'countries/intl_enabled', to: 'shopping/countries#intl_enabled'
      get 'countries/enabled_countries', to: 'shopping/countries#enabled_countries'

      namespace :shopping do
        resources :discounts, only: [:show]
        resources :customer_orders, only: [:show] do
          post :update_address, on: :member
          post :confirm_address, on: :member
        end
        resources :products do
          # match '/product/:product_id', to: 'shopping#product'
        end

        resources :product_groups, only: [:index]

        resources :marketplace do
          get :guide_button, on: :collection
          get :guide_button_redirect, on: :collection
        end
        resources :users do
          post :multipass, on: :collection
          get :multipass, on: :collection
          get :add_to_cart, on: :collection
        end
      end

      post 'premium/generate_cert_and_send_email', to: 'premium_gift_certificate#generate_cert_and_send_email'

      resources :charges, only: [:create] do
        put :redeem, on: :member
      end

      resource :webhooks, only: [:shopify] do
        post :shopify, on: :collection
      end

      resources :products, only: [:index]

      match '/*path' => 'base#options', :via => :options

      # match 'activities/', to: 'activities#index', via: [:get, :options]
      # match 'activities/:id', to: 'activities#show', as: 'activity', via: [:get, :options]

      resources :random_drops, only: [:show]

      resources :cook_history do
        get :find_by_guide, on: :collection
      end
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
