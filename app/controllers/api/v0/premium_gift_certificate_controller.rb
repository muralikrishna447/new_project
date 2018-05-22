require_dependency 'external_service_token_checker'
module Api
  module V0
    class PremiumGiftCertificateController < BaseController
      before_filter BaseController.make_service_filter([ExternalServiceTokenChecker::SPREE_SERVICE])

      #This method was added for Spree. When ChefSteps premium is purchased as a gift, Spree calls the method
      #so we don't have to duplicate the code on the Spree side
      def generate_cert_and_send_email
        begin
          unless params[:premium_identifier]
            render_api_response(400, {message: "Missing parameter"})
            return
          end

          was_used = Rails.cache.fetch(params[:premium_identifier])
          if was_used
            render_api_response(201, {message: 'Already created'})
          else
            pgc = PremiumGiftCertificate.create!(purchaser_id: params[:user_id], price: params[:price], redeemed: false)
            PremiumGiftCertificateMailer.prepare(params[:email], pgc.token).deliver
            Rails.cache.write(params[:premium_identifier], 1, expires_in: 7.days)
            render_api_response(200, {message: 'Success'})
          end

        rescue Exception => e
          logger.error "Could not generate premium certificate, or send premium email: #{e}"
          render_api_response(400, {message: e.message})
        end
      end
    end
  end
end
