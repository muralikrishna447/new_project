class Api::UserMeSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :name, :slug, :email, :intercom_user_hash, :avatar_url, :encrypted_bloom_info, :premium, :admin

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
