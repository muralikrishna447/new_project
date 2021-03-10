module Docs
  module V0
    module Components
      extend Dox::DSL::Syntax

      document :api do
        resource 'Components' do
          group 'Components'
        end
      end

      document :index do
        action 'Get components'
      end

      document :show do
        action 'Get a component'
      end

      document :update do
        action 'Update a component'
      end

      document :create do
        action 'Create a component'
      end

      document :destroy do
        action 'Delete a component'
      end
    end
  end
end
