module User::Facebook
  extend ActiveSupport::Concern

  def assign_from_facebook(auth)
    attrs = {
      provider: auth.provider,
      uid: auth.uid,
      name: self.name.blank? ? auth.extra.raw_info.name : self.name
    }
    attrs.merge!({password: Devise.friendly_token[0,20]}) unless persisted?
    assign_attributes(attrs, without_protection: true)
    self
  end

  module ClassMethods
    def facebook_connected_user(auth)
      connected_user(auth) || connect_via_email(auth)
    end

    private

    def connected_user(auth)
      User.where(provider: auth.provider, uid: auth.uid).first
    end

    def connect_via_email(auth)
      user = User.where(email: auth.info.email).first
      return if user.nil?
      user.assign_from_facebook(auth)
    end
  end
end
