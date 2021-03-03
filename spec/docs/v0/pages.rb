module Docs
  module V0
    module Pages
      extend Dox::DSL::Syntax

      document :api do
        resource 'Pages' do
          group 'Pages'
        end
      end

      document :index do
        action 'Get pages'
      end

      document :show do
        action 'Get a page'
      end

      document :update do
        action 'Update a page'
      end

      document :create do
        action 'Create a page'
      end
    end
  end
end
