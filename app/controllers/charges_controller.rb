class ChargesController < ApplicationController

  respond_to :json

  # Very temporary hack to deal with: Enrollment failed with error: undefined method `enrollments' for nil:NilClass
  skip_before_filter :verify_authenticity_token

  def create
    assembly = Assembly.find(params[:assembly_id])
    @gift_info = JSON.parse(params[:gift_info]) if params[:gift_info]
    @free_trial = params[:free_trial]

    case
    when is_a_gift_purchase? # This is for *buying* a gift certificate
      @gift_cert = GiftCertificate.purchase(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken], @gift_info, params[:existingCard])
    when is_a_gift_redemption? # This is for *redeeming* a gift certificate
      @enrollment = GiftCertificate.redeem(current_user, JSON.parse(params[:gift_certificate])["id"])
      session[:gift_token] = nil
    when is_a_free_trial? # This is for doing a free trial right now it's really similar to normal course but with an extra param
      hours = Assembly.free_trial_hours(@free_trial)
      @enrollment = Enrollment.enroll_user_in_assembly(current_user, request.remote_ip, assembly, 0, nil, hours)
      session.delete(:free_trial)
      if @enrollment && mixpanel_anonymous_id
        mixpanel.track(current_user.email, 'Free Trial Enrolled', {slug: assembly.slug, length: hours.to_s})
      end
    else # Normal course enrollment (paid or free)
      if current_user.enrollments.where(enrollable_id: assembly.id, enrollable_type: assembly.class).first.try(:free_trial?) && assembly.paid? && mixpanel_anonymous_id
        mixpanel.track(current_user.email, "Free Trial Conversion", {slug: assembly.slug, length: current_user.class_enrollment(assembly).free_trial_length.to_s})
      end
      if assembly.paid?
        mixpanel.track(current_user.email, "#{assembly.assembly_type} Purchased Server Side", {slug: assembly.slug})
      end
      if params[:existingCard]
        @enrollment = Enrollment.enroll_user_in_assembly(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken], 0, params[:existingCard])
      else
        @enrollment = Enrollment.enroll_user_in_assembly(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken])
      end
      if assembly.paid?
        # TIMDISCOUNT but probably generally a good idea - our coupons are only good for one paid class purchase
        # so clear 'em out. If the user goes back through a link for a normal coupon again, that would be allowed
        # but not for the the tim discount, since that has its own db flag.
        session[:coupon] = nil
      end
    end

    track_event @enrollment if @enrollment.present?

    head :no_content

  # If anything goes wrong and we weren't able to complete the charge & enrollment, tell the frontend
  rescue Exception => e
    msg = (e.message || "(blank)")
    logger.info "Enrollment failed with error: " + msg
    logger.info "Backtrace: "
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

  def is_a_free_trial?
    @free_trial.present?
  end

end
