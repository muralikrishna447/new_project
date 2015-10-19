class Api::StepSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :order, :title, :directions, :image, :is_aside, :youtube_id, :vimeo_id, :hide_number, :id

  has_many :ingredients, serializer: Api::StepIngredientSerializer

  def order
    object.step_order
  end

  def image
    filepicker_to_s3_url(object.image_id)
  end

end
