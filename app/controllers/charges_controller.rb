class ChargesController < ApplicationController

  respond_to :json

  def adjust_for_included_tax(price, ip)
    tax = 0
    location = Geokit::Geocoders::IpGeocoder.geocode(ip)
    if location.state == "WA"
      tax_rate = 0.095
      tax = (price - (price / (1 + tax_rate))).round(2)
    end
    [(price - tax).round(2), tax]
  end

  def create
    
    assembly = Assembly.find(params[:assembly_id])

    if Enrollment.where(user_id: current_user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      raise "You are already enrolled, we don't want to take your money again!"
    end

    if ! current_user.stripe_id
      customer = Stripe::Customer.create(
        email: current_user.email,
        card: params[:stripeToken]
      )
      current_user.stripe_id = customer.id
      current_user.save!
    end

    extra_descrip = ""
    gross_price, tax = adjust_for_included_tax(assembly.price, request.remote_ip)
    if tax > 0
      extra_descrip = " (including #{ActionController::Base.helpers.number_to_currency(tax)} WA state sales tax)"
    end

    charge = Stripe::Charge.create(
      customer: current_user.stripe_id,
      amount: (assembly.price * 100).to_i,
      description: assembly.title + extra_descrip,
      currency: 'usd'
    )

    # Kinda unclear what we should do here if we succesfully charged their card but 
    # then saving the enrollment fails. Shouldn't happen though... famous last words.
    @enrollment = Enrollment.new(user_id: current_user.id, enrollable: assembly, price: gross_price, sales_tax: tax)
    @enrollment.save!

    head :no_content
  end

  rescue_from 'xException' do |e|
    puts e.message
    messages = []
    messages.push(e.message)
    render json: { errors: messages}, status: 422
  end
end
