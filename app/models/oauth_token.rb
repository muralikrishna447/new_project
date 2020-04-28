class OauthToken < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :service, :user_id, :token, :token_expires_at
  validates_inclusion_of :service, in: %w[ge]
  validates_uniqueness_of :service, scope: :user_id

  scope :ge, -> { where(service: "ge") }

end
