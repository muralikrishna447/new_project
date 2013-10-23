module ApplicationHelper
  def s3_image_url(image_id)
    "//d2eud0b65jr0pw.cloudfront.net/#{image_id}"
  end

  def filepicker_arbitrary_image(fpfile, width, fit='max')
    if ! fpfile
      ""
    elsif ! fpfile.start_with?('{')
      # Legacy naked S3 image id. Still used for a few images that don't
      # have UI to set.
      if /placehold/.match(fpfile)
        fpfile
      else
        s3_image_url(fpfile)
      end
    else
      url = ActiveSupport::JSON.decode(fpfile)["url"]
      url = url + "/convert?fit=#{fit}&w=#{width}&h=#{(width * 9.0 / 16.0).floor}&cache=true"
      # Route through CDN
      url.gsub("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
    end
  end

  def filepicker_hero_image(fpfile)
    filepicker_arbitrary_image(fpfile, 1170)
  end

  def filepicker_activity_hero_image(fpfile)
    filepicker_arbitrary_image(fpfile, 570)
  end

  def filepicker_gallery_image(fpfile)
    filepicker_arbitrary_image(fpfile, 370)
  end

  def filepicker_slider_image(fpfile)
    filepicker_arbitrary_image(fpfile, 355)
  end

  def filepicker_step_image(fpfile)
    filepicker_arbitrary_image(fpfile, 480)
  end

  def filepicker_admin_image(fpfile)
    filepicker_arbitrary_image(fpfile, 200)
  end

  def filepicker_image_description(fpfile, description)
    if ! description.blank?
      description
    else
      if fpfile.start_with?('{')
        ActiveSupport::JSON.decode(fpfile)["filename"]
      else
        # Legacy naked S3 image id. Still used for a few images that don't
        # have UI to set.
        fpfile
      end
    end
  end

  def filepicker_circle_image(fpfile, width=400)
    if fpfile && !fpfile.blank?
      url = ActiveSupport::JSON.decode(fpfile)["url"]
      url + "/convert?fit=crop&w=#{width}&h=#{width}&cache=true"
    else
      "//www.placehold.it/#{width}x#{width}&text=ChefSteps"
    end
  end

  def filepicker_square_image(fpfile, width=400)
    if fpfile && !fpfile.blank?
      url = ActiveSupport::JSON.decode(fpfile)["url"]
      url + "/convert?fit=crop&w=#{width}&h=#{width}&cache=true"
    else
      "//www.placehold.it/#{width}x#{width}&text=ChefSteps"
    end
  end

  def filepicker_media_box_image(fpfile)
    filepicker_arbitrary_image(fpfile, 278, 'crop')
  end

  def filepicker_stream_image(fpfile)
    filepicker_arbitrary_image(fpfile, 770, 'crop')
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
        "<span class='temperature'>#{(contents.to_f * 1.8).round + 32}&nbsp;&deg;F / #{contents}&nbsp;&deg;C</span>"

      when 'f'
        "<span class='temperature'>#{contents}&nbsp;&deg;F / #{((contents.to_f - 32) / 1.8).round}&nbsp;&deg;C</span>"

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
    (text || '').gsub(/\[(\w+)\s+([^\]]*)\]/) do |orig|
      shortcode = $1
      contents = $2
      apply_shortcode(orig, shortcode, contents).html_safe
    end
  end

  def where_user_left_off_in_course(course, user, btn_class = nil)
    last_viewed_activity = user.last_viewed_activity_in_course(course)
    if last_viewed_activity
      link_to "Continue Course #{content_tag :i, nil, class: 'icon-chevron-right'}".html_safe, [course, last_viewed_activity], class: btn_class
    else
      first_activity = course.first_published_activity
      link_to "Start the Course #{content_tag :i, nil, class: 'icon-chevron-right'}".html_safe, [course, first_activity], class: btn_class
    end
  end

  def link_to_web_email(email)
    email_service = /\@(.*)/.match(email).to_s
    case email_service
    when '@gmail.com'
      email_service_name = 'Gmail'
      email_service_url = 'http://www.gmail.com'
    when '@hotmail.com'
      email_service_name = 'Hotmail'
      email_service_url = 'http://www.hotmail.com'
    when '@yahoo.com'
      email_service_name = 'Yahoo Mail'
      email_service_url = 'http://mail.yahoo.com'
    else
      email_service_name = nil
      email_service_url = nil
    end
    if email_service_name && email_service_url
      link_to "Go to #{email_service_name}", email_service_url, class: 'btn btn-primary btn-large', target: '_blank'
    else
      nil
    end
  end

  def buy_now(variant_id, price, mixpanel_track = nil)
    link_to "Buy Now for $#{price}", 'http://store.chefsteps.com/cart/add', onclick: "#{mixpanel_track} var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href; var v = document.createElement('input'); v.setAttribute('type', 'hidden'); v.setAttribute('name', 'id'); v.setAttribute('value', '#{variant_id}'); f.appendChild(v); var r = document.createElement('input'); r.setAttribute('type', 'hidden'); r.setAttribute('name', 'return_to'); r.setAttribute('value', 'http://store.chefsteps.com/checkout'); f.appendChild(r); f.submit(); return false;", class: 'btn btn-primary btn-large btn-block'
    # link_to "Buy Now for $#{price}", "http://store.chefsteps.com/cart/#{variant_id}:1", class: 'btn btn-primary btn-large btn-block'
    # link_to "Buy Now for $#{price}", "http://store.chefsteps.com/cart/add.js?quantity=1&id=#{variant_id}", method: :post, class: 'btn btn-primary btn-large btn-block'
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", ""), parent: association})
  end

  def parse_feed(url)
    doc = SimpleRSS.parse open(url)
  end

  def assembly_type_path(assembly)
    if assembly.assembly_type?
      assembly_type_path = assembly.assembly_type.downcase.pluralize
      assembly_path(assembly).gsub('/assemblies', "/#{assembly_type_path}")
    else
      assembly_path(assembly)
    end
  end

  def current_admin?
    (current_user && current_user.admin?)
  end

  def http_referer_uri
    request.env["HTTP_REFERER"] && URI.parse(request.env["HTTP_REFERER"])
  end

  def class_activity_path(assembly, activity)
    if assembly && activity
      "/classes/#{assembly.slug}/##{activity.slug}"
    end
  end

  def markdown(text)
    # options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
    # syntax_highlighter(Redcarpet.new(text, *options).to_html).html_safe
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
    markdown.render(text)
  end

end

