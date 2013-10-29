class Enrollment < ActiveRecord::Base
  include ActsAsChargeable

  attr_accessible :course_id, :user_id, :enrollable, :price, :sales_tax, :gift_certificate_id
  belongs_to :user
  belongs_to :enrollable, polymorphic: true
  has_many :events, as: :trackable, dependent: :destroy
  has_one :gift_certificate

  validates :enrollable_id, uniqueness: {scope: [:user_id, :enrollable_type], message: 'can only be enrolled once per student.'}

  def self.enroll_user_in_assembly(user, ip_address, assembly, discounted_price, stripe_token)

    if Enrollment.where(user_id: user.id, enrollable_id: assembly.id, enrollable_type: 'Assembly').first
      raise "You are already enrolled!"
    end

    # We create the enrollment first, but wrap this whole block in a transaction, so if the stripe chage then fails,
    # the enrollment is rolled back. The exception will then be re-raised and should be handled
    # by the caller. You don't want to charge first and then create the enrollement, b/c if
    # the charge succeeds and the enrollment fails, you are hosed.
    @enrollment = nil
    Enrollment.transaction do 
      gross_price, tax, extra_descrip = get_tax_info(assembly.price, discounted_price, ip_address)
      @enrollment = Enrollment.create!(user_id: user.id, enrollable: assembly, price: gross_price, sales_tax: tax)
      collect_money(assembly.price, discounted_price, assembly.title, extra_descrip, user, stripe_token)
    end

    @enrollment
  end
end
