class Enrollment < ActiveRecord::Base
  attr_accessible :course_id, :user_id, :enrollable, :price, :sales_tax
  belongs_to :user
  belongs_to :enrollable, polymorphic: true
  has_many :events, as: :trackable, dependent: :destroy

  # validates :course_id, uniqueness: {scope: :user_id, message: 'can only be enrolled once per student.'}
  validates :enrollable_id, uniqueness: {scope: [:user_id, :enrollable_type], message: 'can only be enrolled once per student.'}

  def self.enroll_user_in_assembly(user, ip_address, assembly, discounted_price, stripe_token)

    if Enrollment.where(user_id: user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      raise "You are already enrolled!"
    end

    # Compute any tax adjustments
    gross_price = tax = 0
    if assembly.price && assembly.price > 0
      gross_price, tax = adjust_for_included_tax(discounted_price, ip_address)
      extra_descrip = get_tax_description(tax) 
    end

    # We create the enrollment first, but wrap this whole block in a transaction, so if the stripe chage then fails,
    # the enrollment is rolled back. The exception will then be re-raised and end up in the rescue below.
    @enrollment = nil
    Enrollment.transaction do 

      @enrollment = Enrollment.new(user_id: user.id, enrollable: assembly, price: gross_price, sales_tax: tax)
      @enrollment.save!

      # Take their money. Check assembly price, not discounted_price, to prevent an attack where someone
      # adjusts the price they post back to us. This wouldn't stop them from reducing the price to a low number,
      # but they will still have to provide a valid card.
      if assembly.price && assembly.price > 0
        set_stripe_id_on_user(user, stripe_token)
        charge = Stripe::Charge.create(
          customer: user.stripe_id,
          amount: (discounted_price * 100).to_i,
          description: assembly.title + extra_descrip,
          currency: 'usd'
        )
      end
    end

    @enrollment
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

  def self.get_tax_description(tax)
    if tax > 0
      " (including #{ActionController::Base.helpers.number_to_currency(tax)} WA state sales tax)" 
    else
      ""
    end
  end

end
