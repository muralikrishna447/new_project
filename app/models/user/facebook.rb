module User::Facebook
  extend ActiveSupport::Concern

  def assign_from_facebook(auth)
    attrs = {
      provider: auth.provider,
      facebook_user_id: auth.uid,
      name: self.name.blank? ? auth.extra.raw_info.name : self.name
    }
    update_password = !(persisted? || self.password.present?)
    attrs.merge!({password: Devise.friendly_token[0,20]}) if update_password
    assign_attributes(attrs, without_protection: true)
    self
  end

  def connected_with_facebook?
    facebook_user_id.present? && provider == 'facebook'
  end

  def facebook_connect(user_options)
    self.update_attributes({facebook_user_id: user_options[:user_id], provider: "facebook"}, without_protection: true)
  end

  module ClassMethods
    def facebook_connect(user)
      user_options = {email: user[:email], provider: user[:provider], facebook_user_id: user[:uid]}
      User.where("users.email = :email OR (users.provider = :provider AND users.facebook_user_id = :facebook_user_id)", user_options).
        first_or_initialize(user_options.merge(password: Devise.friendly_token[0,20], name: user[:name]), without_protection: true)
    end

    def facebook_connected_user(auth)
      connected_user(auth) || connect_via_email(auth)
    end

    private

    def connected_user(auth)
      User.where(provider: auth.provider, facebook_user_id: auth.uid).first
    end

    def connect_via_email(auth)
      user = User.where(email: auth.info.email).first
      return if user.nil?
      user.assign_from_facebook(auth)
    end
  end
end
