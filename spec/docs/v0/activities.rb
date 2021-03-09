module Docs
  module V0
    module Activities
      extend Dox::DSL::Syntax

      document :api do
        resource 'Activities' do
          group 'Activities'
        end
      end

      document :index do
        action 'Get activities'
      end

      document :show do
        action 'Get an activity'
      end

      document :likes do
        action 'Get users liked an activity'
      end

      document :likes_by_user do
        action 'Get users like of an activity'
      end
    end
  end
end
