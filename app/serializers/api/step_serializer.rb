class Api::StepSerializer < ActiveModel::Serializer
  attributes :step_order, :title, :directions, :image, :is_aside, :youtube_id, :hide_number

  def image
    filepicker_to_s3_url(object.image_id)
  end

end
