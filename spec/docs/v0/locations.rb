module Docs
  module V0
    module Locations
      extend Dox::DSL::Syntax

      document :api do
        resource 'Locations' do
          group 'Locations'
        end
      end

      document :index do
        action 'Get locations'
      end
    end
  end
end
