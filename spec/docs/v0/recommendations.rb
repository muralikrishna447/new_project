module Docs
  module V0
    module Recommendations
      extend Dox::DSL::Syntax

      document :api do
        resource 'Recommendations' do
          group 'Recommendations'
        end
      end

      document :index do
        action 'Get recommendations'
      end
    end
  end
end
