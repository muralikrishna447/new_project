module Docs
  module V0
    module Users
      extend Dox::DSL::Syntax

      document :api do
        resource 'Users' do
          group 'Users'
        end
      end

      document :me do
        action 'Get user'
      end

      document :make_premium do
        action 'Make premium member'
      end

      document :update do
        action 'Update a user'
      end

      document :create do
        action 'Create a user'
      end

      document :log_upload_url do
        action 'Generate an upload url'
      end

      document :capabilities do
        action 'Get capabilities'
      end

      document :update_settings do
        action 'Update settings'
      end

      document :update_my_settings do
        action 'Update my settings'
      end

      document :update_user_consent do
        action 'Update user consent'
      end

      document :mailchimp_webhook do
        action 'Mailchimp webhook'
      end
    end
  end
end
