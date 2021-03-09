module Docs
  module V0
    module CookHistory
      extend Dox::DSL::Syntax

      document :api do
        resource 'CookHistory' do
          group 'CookHistory'
        end
      end

      document :index do
        action 'Get cook history'
      end

      document :find_by_guide do
        action 'Find by guide'
      end

      document :create do
        action 'Create a cook history'
      end

      document :destroy do
        action 'Delete a cook history'
      end
    end
  end
end
