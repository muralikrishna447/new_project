class Api::StepSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :order, :title, :directions, :image, :is_aside, :youtube_id, :vimeo_id, :hide_number, :id, :appliance_instruction_text, :appliance_image, :can_calculate

  has_many :ingredients, serializer: Api::ActivityIngredientSerializer

  def order
    object.step_order
  end

  def image
    filepicker_to_s3_url(object.image_id)
  end

  def appliance_image
    case object.appliance_instruction_image_type
    when 'smart_over_air'
      'https://d92f495ogyf88.cloudfront.net/static/smart-over-air.png'
    when 'control_freak'
      'https://d92f495ogyf88.cloudfront.net/static/control-freak.png'
    else
      filepicker_to_s3_url(object.appliance_instruction_image)
    end
  end

  def can_calculate
    object.custom?
  end

  def title
    CGI.unescapeHTML(object.title.to_s)
  end

  def appliance_instruction_text
    CGI.unescapeHTML(object.appliance_instruction_text.to_s)
  end
end
