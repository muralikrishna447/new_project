module ApplicationHelper
  include ActionView::Helpers::AssetTagHelper

  def facebook_image_url(uid)
    "https://graph.facebook.com/#{uid}/picture"
  end

  def facebook_edit_url
    "https://www.facebook.com"
  end

  def gravatar_edit_url
    "https://en.gravatar.com/site/signup/"
  end

  def s3_image_url(image_id)
    "http://d2eud0b65jr0pw.cloudfront.net/#{image_id}"
  end

  def is_current_user?(user)
    current_user == user
  end

  def default_profile_photo_url
    image_path('profile-placeholder.png')
  end
end

