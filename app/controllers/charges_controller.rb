class ChargesController < ApplicationController

  respond_to :json

  def create

    assembly = Assembly.find(params[:assembly_id])

    if Enrollment.where(user_id: current_user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      raise "You are already enrolled, we don't want your money again!"
    end

    puts current_user.inspect
    if ! current_user.stripe_id
      customer = Stripe::Customer.create(
        email: current_user.email,
        card: params[:stripeToken]
      )
      puts customer.inspect
      current_user.stripe_id = customer.id
      current_user.save!
    end

    charge = Stripe::Charge.create(
      customer: current_user.stripe_id,
      amount: (assembly.price * 100).to_i,
      description: assembly.title,
      currency: 'usd'
    )

    # Kinda unclear what we should do here if we succesfully charged their card but 
    # then saving the enrollment fails
    @enrollment = Enrollment.new(user_id: current_user.id, enrollable: assembly)
    @enrollment.save!

    head :no_content
  end

  rescue_from 'Exception' do |e|
    puts e.message
    messages = []
    messages.push(e.message)
    render json: { errors: messages}, status: 422
  end
end
