module ActsAsChargeable
  extend ActiveSupport::Concern

  module ClassMethods
    def get_tax_info(base_price, discounted_price, ip_address)
      # Compute any tax adjustments
      gross_price = tax = 0
      extra_descrip = ""
      if base_price && base_price > 0
        gross_price, tax = adjust_for_included_tax(discounted_price, ip_address)
        extra_descrip = get_tax_description(tax) 
      end
      return gross_price, tax, extra_descrip
    end

    # Take their money. Check base price, not discounted_price, to prevent an attack where someone
    # adjusts the price they post back to us. This wouldn't stop them from reducing the price to a low number,
    # but they will still have to provide a valid card.
    def collect_money(base_price, user, stripe_token)
      if base_price && base_price > 0
        set_stripe_id_on_user(user, stripe_token)
        charge = Stripe::Charge.create(
          customer: user.stripe_id,
          amount: (discounted_price * 100).to_i,
          description: assembly.title + extra_descrip,
          currency: 'usd'
        )
      end
    end
  end

  private

  def self.adjust_for_included_tax(price, ip)
    tax = 0
    location = Geokit::Geocoders::IpGeocoder.geocode(ip)
    if location.state == "WA"
      tax_rate = 0.095
      tax = (price - (price / (1 + tax_rate))).round(2)
    end
    [(price - tax).round(2), tax]
  end

  def self.get_tax_description(tax)
    if tax > 0
      " (including #{ActionController::Base.helpers.number_to_currency(tax)} WA state sales tax)" 
    else
      ""
    end
  end

  def self.set_stripe_id_on_user(user, stripeToken)
    # Create the stripe user if not already known
    if ! user.stripe_id
      customer = Stripe::Customer.create(
        email: user.email,
        card: stripeToken
      )
      user.stripe_id = customer.id
      user.save!
    end
  end

end

