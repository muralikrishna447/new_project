class Enrollment < ActiveRecord::Base
  include ActsAsChargeable

  attr_accessible :course_id, :user_id, :enrollable, :price, :sales_tax, :gift_certificate_id
  belongs_to :user
  belongs_to :enrollable, polymorphic: true
  has_many :events, as: :trackable, dependent: :destroy
  has_one :gift_certificate

  validates :enrollable_id, uniqueness: {scope: [:user_id, :enrollable_type], message: 'can only be enrolled once per student.'}

  class << self
    def enroll_user_in_assembly(user, ip_address, assembly, discounted_price, stripe_token, free_trial_hours=0)
      enrollment = Enrollment.where(user_id: user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      raise "You are already enrolled!" if enrollment.present? && !enrollment.free_trial?

      @enrollment = nil

      # Logic control flow
      Enrollment.transaction do
        case
        when assembly.paid_class? && free_trial_hours > 0 # Paid Class and Free Trial
          free_trial_enrollment(user, ip_address, assembly, discounted_price, stripe_token, free_trial_hours)
        when assembly.paid_class? && free_trial_hours == 0 # Paid Class and No Free Trial
          paid_enrollment(user, ip_address, assembly, discounted_price, stripe_token)
        when !assembly.paid_class? # Free Class
          free_enrollment(user, ip_address, assembly, discounted_price, stripe_token)
        end
      end

      # Return the enrollment
      @enrollment
    end

    def paid_enrollment(user, ip_address, assembly, discounted_price, stripe_token)
      # We create the enrollment first, but wrap this whole block in a transaction, so if the stripe chage then fails,
      # the enrollment is rolled back. The exception will then be re-raised and should be handled
      # by the caller. You don't want to charge first and then create the enrollement, b/c if
      # the charge succeeds and the enrollment fails, you are hosed.
      gross_price, tax, extra_descrip = get_tax_info(assembly.price, discounted_price, ip_address)
      enrollment = Enrollment.where(user_id: user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      if enrollment && enrollment.free_trial?
        enrollment.update_attributes({price: gross_price, sales_tax: tax, trial_expires_at: nil}, without_protection: true)
        @enrollment = enrollment
      else
        @enrollment = Enrollment.create!(user_id: user.id, enrollable: assembly, price: gross_price, sales_tax: tax)
      end
      collect_money(assembly.price, discounted_price, assembly.title, extra_descrip, user, stripe_token)
    end

    def free_enrollment(user, ip_address, assembly, discounted_price, stripe_token)
      @enrollment = Enrollment.create!(user_id: user.id, enrollable: assembly, price: 0, sales_tax: 0)
    end

    def free_trial_enrollment(user, ip_address, assembly, discounted_price, stripe_token, free_trial_hours)
      @enrollment = Enrollment.create!(user_id: user.id, enrollable: assembly, price: 0, sales_tax: 0) do |e|
        e.trial_expires_at = (Time.now+(free_trial_hours.hours))
      end
    end
  end

  def free_trial?
    trial_expires_at.present?
  end

  def free_trial_expired?
    free_trial? && trial_expires_at < Time.now
  end

  def free_trial_length
    return nil unless free_trial?
    ((trial_expires_at - created_at)/1.hours).round
  end
end
