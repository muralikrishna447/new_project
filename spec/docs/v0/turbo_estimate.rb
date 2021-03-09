module Docs
  module V0
    module TurboEstimate
      extend Dox::DSL::Syntax

      document :api do
        resource 'TurboEstimate' do
          group 'TurboEstimate'
        end
      end

      document :get_turbo_estimate do
        action 'Get turbo estimate'
      end
    end
  end
end
