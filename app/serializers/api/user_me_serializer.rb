class Api::UserMeSerializer < ApplicationSerializer
  # TODO: the controller that uses this wasn't previously returning lowerCamel. Fixing
  # that will break some clients so not doing it now.
  #format_keys :lower_camel

  attributes :id, :name, :slug, :email, :intercom_user_hash, :avatar_url, :encrypted_bloom_info, :premium, :used_circulator_discount, :admin

  def intercom_user_hash
    ApplicationController.new.intercom_user_hash(object)
  end

  def premium
    object.premium?
  end

  def admin
    object.admin?
  end
end
