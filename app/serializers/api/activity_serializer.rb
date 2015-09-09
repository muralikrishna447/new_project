class Api::ActivitySerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :description, :image, :youtube_id, :vimeo_id, :url, :likes_count, :yield, :timing , :short_description, :tag_list, :source_activity_id, :chefsteps_generated

  has_one :creator, serializer: Api::ProfileSerializer

  has_many :ingredients, serializer: Api::ActivityIngredientSerializer
  has_many :steps, serializer: Api::StepSerializer
  has_many :equipment, serializer: Api::ActivityEquipmentSerializer
  
  def image
    filepicker_to_s3_url(object.featured_image)
  end

  def url
    activity_url(object)
  end

  def chefsteps_generated
    object.chefsteps_generated
  end

end
