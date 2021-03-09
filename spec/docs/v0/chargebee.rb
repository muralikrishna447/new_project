module Docs
  module V0
    module Chargebee
      extend Dox::DSL::Syntax

      document :api do
        resource 'Chargebee' do
          group 'Chargebee'
        end
      end

      document :webhook do
        action 'Call webhook'
      end

      document :sync_subscriptions do
        action 'Sync subscriptions'
      end

      document :switch_subscription do
        action 'Switch subscription'
      end

      document :generate_checkout_url do
        action 'Generate checkout url'
      end

      document :gifts do
        action 'Get gifts'
      end

      document :claim_gifts do
        action 'Claim gifts'
      end

      document :claim_complete do
        action 'Claim complete'
      end

      document :generate_checkout_url do
        action 'Generate checkout url'
      end
    end
  end
end
