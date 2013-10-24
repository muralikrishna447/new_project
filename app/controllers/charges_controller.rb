class ChargesController < ApplicationController

  respond_to :json

  def create
    
    assembly = Assembly.find(params[:assembly_id])
    @enrollment = Enrollment.enroll_user_in_assembly(current_user, request.remote_ip, assembly, params[:discounted_price].to_f, params[:stripeToken])
    track_event @enrollment
    head :no_content

  # If anything goes wrong and we weren't able to complete the charge & enrollment, tell the frontend
  rescue Exception => e
    msg = (e.message || "(blank)")
    logger.debug "Enrollment failed with error: " + msg
    logger.debug "Backtrace: "
    logger.debug e.backtrace
    render json: { errors: [msg]}, status: 422
  end
end
