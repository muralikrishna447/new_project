module Docs
  module V0
    module Passwords
      extend Dox::DSL::Syntax

      document :api do
        resource 'Passwords' do
          group 'Passwords'
        end
      end

      document :update do
        action 'Update password'
      end

      document :update_from_email do
        action 'Update from email'
      end

      document :send_reset_email do
        action 'Reset password'
      end
    end
  end
end
