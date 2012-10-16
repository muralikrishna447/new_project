Delve::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  get "styleguide" => "styleguide#index"

  

  devise_for :users

  root to: "home#index"

  post 'subscribe' => "mailing_list#subscribe", as: 'mailing_list_subscribe'

  resources :courses, :only => [:show]
  resources :activities, :only => [:show] do
    member do
      post 'cooked-this' => 'activities#cooked_this', as: 'cooked_this'
    end
  end

end

