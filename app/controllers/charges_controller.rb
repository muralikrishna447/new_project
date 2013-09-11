class ChargesController < ApplicationController

  respond_to :json

  def create
    # Amount in cents
    assembly = Assembly.find(params[:assembly_id])

    customer = Stripe::Customer.create(
      email: current_user.email,
      card: params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: (assembly.price * 100).to_i,
      description: assembly.title,
      currency: 'usd'
    )

    head :no_content
  end

  rescue_from 'Exception' do |e|
    puts e.message
    messages = []
    messages.push(e.message)
    render json: { errors: messages}, status: 422
  end
end
