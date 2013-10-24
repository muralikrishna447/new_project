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
    discounted_price = params[:discounted_price].to_f

    if Enrollment.where(user_id: current_user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      raise "You are already enrolled, we don't want to take your money again!"
    end

    # Compute any tax adjustments
    gross_price = tax = 0
    if assembly.price && assembly.price > 0
      gross_price, tax = adjust_for_included_tax(discounted_price, request.remote_ip)
      extra_descrip = get_tax_description(tax) 
    end

    # We create the enrollment first, but wrap this whole block in a transaction, so if the stripe chage then fails,
    # the enrollment is rolled back. The exception will then be re-raised and end up in the rescue below.
    Enrollment.transaction do 

      @enrollment = Enrollment.new(user_id: current_user.id, enrollable: assembly, price: gross_price, sales_tax: tax)
      @enrollment.save!
      track_event @enrollment

      # Take their money. Check assembly price, not discounted_price, to prevent an attack where someone
      # adjusts the price they post back to us. This wouldn't stop them from reducing the price to a low number,
      # but they will still have to provide a valid card.
      if assembly.price && assembly.price > 0
        set_stripe_id_on_user(params[:stripeToken])
        charge = Stripe::Charge.create(
          customer: current_user.stripe_id,
          amount: (discounted_price * 100).to_i,
          description: assembly.title + extra_descrip,
          currency: 'usd'
        )
      end

      head :no_content
    end

  # If anything goes wrong and we weren't able to complete the charge & enrollment, tell the frontend
  rescue Exception => e
    msg = (e.message || "(blank)")
    logger.debug "Enrollment failed with error: " + msg
    logger.debug "Backtrace: "
    logger.debug e.backtrace
    render json: { errors: [msg]}, status: 422
  end


  private

  def set_stripe_id_on_user(stripeToken)
    # Create the stripe user if not already known
    if ! current_user.stripe_id
      customer = Stripe::Customer.create(
        email: current_user.email,
        card: stripeToken
      )
      current_user.stripe_id = customer.id
      current_user.save!
    end
  end

  def get_tax_description(tax)
    if tax > 0
      " (including #{ActionController::Base.helpers.number_to_currency(tax)} WA state sales tax)" 
    else
      ""
    end
  end

end
