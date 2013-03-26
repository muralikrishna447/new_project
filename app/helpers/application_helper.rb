module ApplicationHelper
  def s3_image_url(image_id)
    "http://d2eud0b65jr0pw.cloudfront.net/#{image_id}"
  end

  def filepicker_arbitrary_image(url, width)
    if ! url.start_with?('http://', 'https://')
      # Legacy naked S3 image ref
      s3_image_url(url)
    else
      url + "/convert?fit=max&w=#{width}&h=#{(width * 16.0 / 9.0).floor}"
    end
  end

  def filepicker_hero_image(url)
    filepicker_arbitrary_image(url, 1170)
  end

  def filepicker_activity_hero_image(url)
    filepicker_arbitrary_image(url, 570)
  end

  def filepicker_gallery_image(url)
    filepicker_arbitrary_image(url, 370)
  end

  def filepicker_slider_image(url)
    filepicker_arbitrary_image(url, 355)
  end

  def filepicker_step_image(url)
    filepicker_arbitrary_image(url, 480)
  end

  def filepicker_admin_image(url)
    filepicker_arbitrary_image(url, 200)
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

  def current_url(request)
    # "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    "#{request.protocol}www.chefsteps.com#{request.fullpath}"
  end

  def fb_like(url)
    "<iframe src='//www.facebook.com/plugins/like.php?href=#{Rack::Utils.escape(url)}&amp;send=false&amp;layout=standard&amp;width=248&amp;show_faces=true&amp;font=arial&amp;colorscheme=light&amp;action=like&amp;height=80&amp;appId=380147598730003' scrolling='no' frameborder='0' style='border:none; overflow:hidden; width:248px; height:80px;' allowTransparency='true'></iframe>"
  end

  def course_syllabus(course)
    render 'courses/syllabus', course: course
  end

  def apply_shortcode(orig, shortcode, contents)
    case shortcode
      when 'c'
        "<a class='temperature-group'><span class='temperature'>#{contents}</span> <span class='temperature-unit'>&deg;C</span></a>"

      when 'cm'
        "<a class='length-group'><span class='length' data-orig-value='#{contents}'>#{contents} cm</span></a>"

      when 'mm'
        "<a class='length-group'><span class='length' data-orig-value='#{contents.to_f / 10.0}'>#{contents} mm</span></a>"

      when 'g'
        "<span class='text-quantity-group'><span class='quantity-group qtyfade'><span class='lbs-qty'></span> <span class='lbs-label'></span> <span class='main-qty'>#{contents}</span></span> <span class='unit qtyfade'>g</span></span>"

      when 'ea'
        "<span class='text-quantity-group'><span class='quantity-group qtyfade'><span class='lbs-qty'></span> <span class='lbs-label'></span> <span class='main-qty'>#{contents}</span></span> <span class='unit qtyfade alwayshidden'>ea</span></span>"

      when 'amzn'
        asin, anchor_text = contents.split(/\s/, 2)
        link_to anchor_text, "http://www.amazon.com/dp/#{asin}/?tag=delvkitc-20", target: "_blank"

      else
        orig
    end
  end

  def apply_shortcodes(text)
    text.gsub(/\[(\w+)\s+([^\]]*)\]/) do |orig|
      shortcode = $1
      contents = $2
      apply_shortcode(orig, shortcode, contents).html_safe
    end
  end

end

