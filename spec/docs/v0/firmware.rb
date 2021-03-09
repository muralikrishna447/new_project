module Docs
  module V0
    module Firmware
      extend Dox::DSL::Syntax

      document :api do
        resource 'Firmware' do
          group 'Firmware'
        end
      end

      document :updates do
        action 'Get updates'
      end
    end
  end
end
