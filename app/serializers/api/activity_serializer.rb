class Api::ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :image, :youtube_id, :url, :likesCount

  has_many :ingredients, serializer: Api::ActivityIngredientSerializer
  has_many :steps, serializer: Api::StepSerializer
  has_many :equipment

  def image
    filepicker_to_s3_url(object.featured_image_id)
  end

  def url
    activity_url(object)
  end

  def likesCount
    object.likes_count
  end
end
