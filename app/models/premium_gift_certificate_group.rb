class PremiumGiftCertificateGroup < ApplicationRecord
  validates :title, :coupon_count, :created_by_id, presence: true
  validates_uniqueness_of :title
  validates_numericality_of :coupon_count, greater_than: 0, less_than: 5000

  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'

  has_many :premium_gift_certificates


  after_commit :on => %i(create) do
    Resque.enqueue(BatchPremiumCouponGenerator, id)
  end
end
