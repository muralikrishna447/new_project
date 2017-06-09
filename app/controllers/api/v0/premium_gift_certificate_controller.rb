module Api
  module V0
    class PremiumGiftCertificateController < BaseController
      before_filter :ensure_authorized_service

      #This method was added for Spree. When ChefSteps premium is purchased as a gift, Spree calls the method
      #so we don't have to duplicate the code on the Spree side
      def generate_cert
        begin
          pgc = PremiumGiftCertificate.create!(purchaser_id: params[:user_id], price: params[:price], redeemed: false)
          PremiumGiftCertificateMailer.prepare(params[:email], pgc.token).deliver
          render_api_response(200, {message: 'Success'})
        rescue Exception => e
          logger.error "Could not generate premium certificate, or send premium email: #{e}"
          render_api_response(400, {message: e.message})
        end
      end
    end
  end
end

