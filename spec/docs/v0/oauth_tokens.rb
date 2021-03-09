module Docs
  module V0
    module OauthTokens
      extend Dox::DSL::Syntax

      document :api do
        resource 'OauthTokens' do
          group 'OauthTokens'
        end
      end

      document :index do
        action 'Get oauth tokens'
      end
    end
  end
end
