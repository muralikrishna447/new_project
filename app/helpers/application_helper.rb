module ApplicationHelper
  def s3_image_url(image_id)
    "http://d2eud0b65jr0pw.cloudfront.net/#{image_id}"
  end

  def s3_audio_url(audio_clip)
    "<audio controls><source src='http://d2eud0b65jr0pw.cloudfront.net/#{audio_clip}''></source></audio>".html_safe
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

  def add_body_data(data)
    body_data.merge!(data)
  end

  def body_data
    @body_data ||= {}
  end

  def fancy_checkbox_tag(name, value = '1', checked = false, options = {}, &block)
    label_for = options[:id] || name
    content_tag :div, data: {behavior: 'checkbox'} do
      content = check_box_tag name, value, checked, options
      content += label_tag label_for, &block
    end
  end

  def fancy_radio_button_tag(name, value, checked = false, options = {}, &block)
    label_for = options[:id] || "#{name}_#{value}"
    content_tag :div, data: {behavior: 'checkbox'} do
      content = radio_button_tag name, value, checked, options
      content += label_tag label_for, &block
    end
  end

  def apply_shortcode(orig, shortcode, contents)
    case shortcode
      when 'c'
        c = contents
        f = (c.to_f * 1.8 + 32).round
        "#{f} &deg;F / #{c} &deg;C"

      when 'f'
        f = contents
        c = ((f.to_f - 32) / 1.8).round
        "#{f} &deg;F / #{c} &deg;C"

      when 'amzn'
        asin, anchor_text = contents.split(/\s/, 2)
        link_to anchor_text, "http://www.amazon.com/dp/#{asin}/?tag=delvkitc-20"
      else
        orig
    end
  end

  def apply_shortcodes(text)
    text.gsub(/\[(\w+)\s+([^\]]*)\]/) do |orig|
      shortcode = $1
      contents = $2
      apply_shortcode(orig, shortcode, contents)
    end
  end
end

