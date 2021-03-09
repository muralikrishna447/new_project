module Docs
  module V0
    module Likes
      extend Dox::DSL::Syntax

      document :api do
        resource 'Likes' do
          group 'Likes'
        end
      end

      document :create do
        action 'Create a like'
      end

      document :destroy do
        action 'Delete a like'
      end
    end
  end
end
