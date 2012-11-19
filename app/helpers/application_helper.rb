module ApplicationHelper

  def s3_image_url(image_id)
    "http://d2eud0b65jr0pw.cloudfront.net/#{image_id}"
  end

  def is_current_user?(user)
    current_user == user
  end

  def conditional_cache(name = {}, options = nil, &block)
    if options.delete(:cache_unless)
      yield block
    else
      cache(name, options, &block)
    end
  end
end

