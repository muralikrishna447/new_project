module ActsAsChargeable
  extend ActiveSupport::Concern

  module ClassMethods
    def get_tax_info(base_price, discounted_price, ip_address)
      # Compute any tax adjustments
      gross_price = tax = 0.0
      extra_descrip = ""
      if base_price && base_price > 0
        gross_price, tax = self.adjust_for_included_tax(discounted_price, ip_address)
        extra_descrip = self.get_tax_description(tax)
      end
      return gross_price, tax, extra_descrip
    end

    # Take their money.  Check base price, not discounted_price, to prevent an attack where someone
    # adjusts the price they post back to us. This wouldn't stop them from reducing the price to a low number,
    # but they will still have to provide a valid card.
    def collect_money(base_price, discounted_price, item_title, extra_descrip, user, stripe_token)
      if base_price && base_price > 0
        self.set_stripe_id_on_user(user, stripe_token)
        charge = Stripe::Charge.create(
          customer: user.stripe_id,
          amount: (discounted_price * 100).to_i,
          description: item_title + extra_descrip,
          currency: 'usd'
        )
        # puts charge.inspect
      end
    end

    def adjust_for_included_tax(price, ip)
      tax = 0.0
      location = Geokit::Geocoders::IpGeocoder.geocode(ip)
      if location.state == "WA"
        tax_rate = 0.095
        tax = (price - (price / (1 + tax_rate))).round(2)
      end
      [(price - tax).round(2), tax]
    end

    def get_tax_description(tax)
      if tax > 0
        " (including #{ActionController::Base.helpers.number_to_currency(tax)} WA state sales tax)"
      else
        ""
      end
    end

    def set_stripe_id_on_user(user, stripeToken)
      if ! user.stripe_id
        # Create the stripe user if not already known
        customer = Stripe::Customer.create(
          email: user.email,
          card: stripeToken
        )
        user.stripe_id = customer.id
        user.skip_name_validation = true
        user.save!
      else
        # Update the customer's card and email
        customer = Stripe::Customer.retrieve(user.stripe_id)
        customer.card = stripeToken
        customer.email = user.email
        customer.skip_name_validation = true
        customer.save
      end
    end
  end
end

