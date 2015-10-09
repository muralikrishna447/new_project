class Enrollment < ActiveRecord::Base
  include ActsAsChargeable

  attr_accessible :course_id, :user_id, :enrollable, :price, :sales_tax, :gift_certificate_id
  belongs_to :user
  belongs_to :enrollable, polymorphic: true
  has_many :events, as: :trackable, dependent: :destroy
  has_one :gift_certificate

  validates :enrollable_id, uniqueness: {scope: [:user_id, :enrollable_type], message: 'can only be enrolled once per student.'}

  class << self
    def enroll_user_in_assembly(user, ip_address, assembly, discounted_price, stripe_token, existing_card=nil)
      enrollment = Enrollment.where(user_id: user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      raise "You are already enrolled!" if enrollment.present?

      @enrollment = nil

      # Logic control flow
      Enrollment.transaction do
        case
        when assembly.paid? # Paid Class
          paid_enrollment(user, ip_address, assembly, discounted_price, stripe_token, existing_card)
        when !assembly.paid? # Free Class
          free_enrollment(user, ip_address, assembly, discounted_price, stripe_token)
        end
      end
      # Return the enrollment
      @enrollment
    end

    def paid_enrollment(user, ip_address, assembly, discounted_price, stripe_token, existing_card)
      # We create the enrollment first, but wrap this whole block in a transaction, so if the stripe chage then fails,
      # the enrollment is rolled back. The exception will then be re-raised and should be handled
      # by the caller. You don't want to charge first and then create the enrollement, b/c if
      # the charge succeeds and the enrollment fails, you are hosed.
      logger.info("THIS IS A PAID ENROLLMENT")
      gross_price, tax, extra_descrip = get_tax_info(assembly.price, discounted_price, ip_address)
      enrollment = Enrollment.where(user_id: user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      logger.info("Found enrollment #{enrollment}")

      logger.info("Creating enrollment")
      @enrollment = Enrollment.create!(user_id: user.id, enrollable: assembly, price: gross_price, sales_tax: tax)

      logger.info("Collecting money")
      collect_money(assembly.price, discounted_price, assembly.title, extra_descrip, user, stripe_token, existing_card)
    end

    def free_enrollment(user, ip_address, assembly, discounted_price, stripe_token)
      logger.info("Creating free enrollment")
      @enrollment = Enrollment.create!(user_id: user.id, enrollable: assembly, price: 0, sales_tax: 0)
    end

  end

end
