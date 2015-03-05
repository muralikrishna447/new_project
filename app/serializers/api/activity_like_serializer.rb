class Api::ActivityLikeSerializer < ApplicationSerializer
  format_keys :lower_camel

  # id, name, and avatar_url refer to the user, not the like
  # created_at returns the like created_at, not user created_at
  attributes :id, :name, :avatar_url, :created_at, :profile_url

  # Returns the user id, not the like id
  def id
    object.user.id
  end

  def name
    object.user.name
  end

  def avatar_url
    object.user.avatar_url
  end

  def profile_url
    user_profile_url(object.user)
  end

end
