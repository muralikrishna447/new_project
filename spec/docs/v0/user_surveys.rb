module Docs
  module V0
    module UserSurveys
      extend Dox::DSL::Syntax

      document :api do
        resource 'UserSurveys' do
          group 'UserSurveys'
        end
      end

      document :create do
        action 'Create a page'
      end
    end
  end
end
