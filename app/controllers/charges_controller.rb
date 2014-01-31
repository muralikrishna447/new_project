class ChargesController < ApplicationController

  respond_to :json

  def create

    assembly = Assembly.find(params[:assembly_id])
    @gift_info = JSON.parse(params[:gift_info]) if params[:gift_info]
    @free_trial = params[:free_trial]

    case
    when is_a_gift_purchase? # This is for *buying* a gift certificate
      @gift_cert = GiftCertificate.purchase(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken], @gift_info)
    when is_a_gift_redemption? # This is for *redeeming* a gift certificate
      @enrollment = GiftCertificate.redeem(current_user, JSON.parse(params[:gift_certificate])["id"])
      session[:gift_token] = nil
    when is_a_free_trial? # This is for doing a free trial right now it's really similar to normal course but with an extra param
      assembly_from_free_trial, hours = Base64.decode64(@free_trial).split('-').map(&:to_i)
      @enrollment = Enrollment.enroll_user_in_assembly(current_user, request.remote_ip, assembly, 0, nil, hours)
      if @enrollment && mixpanel_anonymous_id
        mixpanel.people.append(current_user.email, {'Free Trial Enrolled' => assembly.slug})
        mixpanel.track(mixpanel_anonymous_id, 'Free Trial Enrolled', {slug: assembly.slug, length: hours})
      end
    else # Normal course enrollment (paid or free)
      if current_user.enrollments.where(enrollable_id: assembly.id, enrollable_type: assembly.class).first.try(:free_trial?) && assembly.price > 0 && mixpanel_anonymous_id
        mixpanel.people.append(current_user.email, {'Free Trial Converted' => assembly.slug})
        mixpanel.track(mixpanel_anonymous_id, "Free Trial Conversion", {slug: assembly.slug, length: current_user.class_enrollment(assembly).free_trial_length})
      end
      @enrollment = Enrollment.enroll_user_in_assembly(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken])
    end

    track_event @enrollment if @enrollment.present?

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

  def is_a_free_trial?
    @free_trial.present?
  end

end
