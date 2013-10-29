class ChargesController < ApplicationController

  respond_to :json

  def create
    
    assembly = Assembly.find(params[:assembly_id])
    gift_info = JSON.parse(params[:gift_info]) if params[:gift_info]

    if defined? gift_info["recipientEmail"]
      # This is for *buying* a gift certificate
      @gift_cert = GiftCertificate.purchase(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken], gift_info)
    else
      @enrollment = nil
      if params[:gift_certificate]
        # This is for *redeeming* a gift certificate
        @enrollment = GiftCertificate.redeem(current_user, JSON.parse(params[:gift_certificate])["id"])

      else
        # Normal course enrollment (paid or free)
        @enrollment = Enrollment.enroll_user_in_assembly(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken])
      end
      track_event @enrollment
    end

    head :no_content

  # If anything goes wrong and we weren't able to complete the charge & enrollment, tell the frontend
  rescue Exception => e
    msg = (e.message || "(blank)")
    logger.debug "Enrollment failed with error: " + msg
    logger.debug "Backtrace: "
    e.backtrace.take(20).each { |x| logger.debug x}
    render json: { errors: [msg]}, status: 422
  end
end
