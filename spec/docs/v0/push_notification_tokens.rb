module Docs
  module V0
    module PushNotificationTokens
      extend Dox::DSL::Syntax

      document :api do
        resource 'PushNotificationTokens' do
          group 'PushNotificationTokens'
        end
      end

      document :create do
        action 'Create a token'
      end

      document :destroy do
        action 'Delete a token'
      end
    end
  end
end
