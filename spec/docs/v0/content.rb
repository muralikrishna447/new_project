module Docs
  module V0
    module Content
      extend Dox::DSL::Syntax

      document :api do
        resource 'Content' do
          group 'Content'
        end
      end

      document :manifest do
        action 'Get manifest'
      end
    end
  end
end
