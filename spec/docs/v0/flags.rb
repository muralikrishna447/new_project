module Docs
  module V0
    module Flags
      extend Dox::DSL::Syntax

      document :api do
        resource 'Flags' do
          group 'Flags'
        end
      end

      document :index do
        action 'Get flags'
      end
    end
  end
end
