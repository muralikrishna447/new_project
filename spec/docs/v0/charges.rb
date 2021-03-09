module Docs
  module V0
    module Charges
      extend Dox::DSL::Syntax

      document :api do
        resource 'Charges' do
          group 'Charges'
        end
      end

      document :create do
        action 'Create a charge'
      end

      document :redeem do
        action 'Redeem a charge'
      end
    end
  end
end
