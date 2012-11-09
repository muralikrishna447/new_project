module ApplicationHelper
  def facebook_image_url(uid)
    "https://graph.facebook.com/#{uid}/picture"
  end

  def s3_image_url(image_id)
    "http://d2eud0b65jr0pw.cloudfront.net/#{image_id}"
  end

  def is_current_user?(user)
    current_user == user
  end
end

