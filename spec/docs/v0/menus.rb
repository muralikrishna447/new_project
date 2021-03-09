module Docs
  module V0
    module Menus
      extend Dox::DSL::Syntax

      document :api do
        resource 'Menus' do
          group 'Menus'
        end
      end

      document :list do
        action 'Get menus'
      end
    end
  end
end
