Delve::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  root to: "home#index"

  resources :courses, :only => [:show] do
    # resources :modules, :only => [] do
    #   resources :topics, :only => [] do
    #     resources :activities, :only => [:show]
    #   end
    # end
  end

  resources :activities, :only => [:show]

end

