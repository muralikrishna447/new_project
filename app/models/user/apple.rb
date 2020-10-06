module User::Apple
  extend ActiveSupport::Concern

  APPLE_USER_DEFAULT_NAME = "ChefSteps User"

  def apple_connect(user_options)
    self.update_attributes(apple_user_id: user_options[:apple_user_id], provider: 'apple')
  end

  module ClassMethods
    def apple_connect(params)
      user_options = {email: params[:email], provider: 'apple', apple_user_id: params[:apple_user_id]}
      name = params[:name].present? ? params[:name] : APPLE_USER_DEFAULT_NAME
      User.where("users.email = :email AND users.provider = :provider AND users.apple_user_id = :apple_user_id", user_options).
        first_or_initialize(user_options.merge(password: Devise.friendly_token[0,20], name: name))
    end
  end
end
