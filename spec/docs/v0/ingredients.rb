module Docs
  module V0
    module Ingredients
      extend Dox::DSL::Syntax

      document :api do
        resource 'Ingredients' do
          group 'Ingredients'
        end
      end

      document :index do
        action 'Get ingredients'
      end

      document :show do
        action 'Get a ingredient'
      end
    end
  end
end
