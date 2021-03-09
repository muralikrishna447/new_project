module Docs
  module V0
    module Circulators
      extend Dox::DSL::Syntax

      document :api do
        resource 'Circulators' do
          group 'Circulators'
        end
      end

      document :index do
        action 'Get Circulators'
      end

      document :create do
        action 'Create a circulator'
      end

      document :token do
        action 'Create a token'
      end

      document :update do
        action 'Update a circulator'
      end

      document :destroy do
        action 'Delete a circulator'
      end

      document :notify_clients do
        action 'Notify clients'
      end

      document :coefficients do
        action 'Get coefficients'
      end
    end
  end
end
