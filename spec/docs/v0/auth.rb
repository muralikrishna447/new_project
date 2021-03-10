module Docs
  module V0
    module Auth
      extend Dox::DSL::Syntax

      document :api do
        resource 'Auth' do
          group 'Auth'
        end
      end

      document :authenticate do
        action 'Get authenticate'
      end

      document :validate do
        action 'Get validate'
      end

      document :logout do
        action 'Get log out'
      end

      document :authorize_ge_redirect do
        action 'Get authorize ge redirect'
      end

      document :authenticate_ge do
        action 'Get authenticate ge'
      end

      document :authenticate_facebook do
        action 'Get authenticate facebook'
      end

      document :authenticate_apple do
        action 'Get authenticate apple'
      end

      document :external_redirect do
        action 'Get external redirect'
      end

      document :upgrade_token do
        action 'Get upgrade token'
      end
    end
  end
end
