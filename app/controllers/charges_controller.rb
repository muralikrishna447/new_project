class ChargesController < ApplicationController

  respond_to :json

  def create

    assembly = Assembly.find(params[:assembly_id])
    @gift_info = JSON.parse(params[:gift_info]) if params[:gift_info]


    if is_a_gift_purchase?
      # This is for *buying* a gift certificate
      @gift_cert = GiftCertificate.purchase(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken], @gift_info)
    else
      @enrollment = nil
      if is_a_gift_redemption?
        # This is for *redeeming* a gift certificate
        @enrollment = GiftCertificate.redeem(current_user, JSON.parse(params[:gift_certificate])["id"])
        session[:gift_token] = nil

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

  private
  def is_a_gift_purchase?
    @gift_info && @gift_info.has_key?("recipientEmail")
  end

  def is_a_gift_redemption?
    params[:gift_certificate]
  end

end
