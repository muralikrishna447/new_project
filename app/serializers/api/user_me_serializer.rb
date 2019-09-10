class Api::UserMeSerializer < ApplicationSerializer
  # TODO: the controller that uses this wasn't previously returning lowerCamel. Fixing
  # that will break some clients so not doing it now.
  #format_keys :lower_camel

  attributes :id, :name, :slug, :email, :avatar_url, :encrypted_bloom_info, :premium, :studio, :used_circulator_discount, :admin, :needs_special_terms, :joule_purchase_count, :referral_code, :capabilities

  has_one :settings, serializer: Api::UserSettingsSerializer
  has_many :subscriptions, serializer: Api::UserSubscriptionsSerializer

  def premium
    object.premium?
  end

  def studio
    object.studio?
  end

  def admin
    object.admin?
  end
  
end
