class Api::StepSerializer < ActiveModel::Serializer
  attributes :order, :title, :directions, :image, :isAside, :youtubeId, :hideNumber

  def order
    object.step_order
  end

  def isAside
    object.is_aside
  end

  def youtubeId
    object.youtube_id
  end

  def hideNumber
    object.hide_number
  end

  def image
    filepicker_to_s3_url(object.image_id)
  end

end
