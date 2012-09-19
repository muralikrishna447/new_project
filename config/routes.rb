Delve::Application.routes.draw do
  get "styleguide" => "styleguide#index"

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

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

