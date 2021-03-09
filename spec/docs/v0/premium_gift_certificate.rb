module Docs
  module V0
    module PremiumGiftCertificate
      extend Dox::DSL::Syntax

      document :api do
        resource 'PremiumGiftCertificate' do
          group 'PremiumGiftCertificate'
        end
      end

      document :generate_cert_and_send_email do
        action 'Generate cert and send email'
      end
    end
  end
end
