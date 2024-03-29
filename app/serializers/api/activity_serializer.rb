class Api::ActivitySerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :used_in, :id, :title, :byline, :description, :image, :youtube_id, :vimeo_id, :url, :likes_count, :yield, :timing
  attributes :short_description, :tag_list, :chefsteps_generated, :hero_image, :premium, :studio
  has_one :user, root: :creator, serializer: Api::ProfileSerializer
  has_one :source_activity, serializer: Api::ActivityIndexSerializer

  has_many :ingredients, serializer: Api::ActivityIngredientSerializer
  has_many :steps, serializer: Api::StepSerializer
  has_many :equipment, serializer: Api::ActivityEquipmentSerializer

  def image
    filepicker_to_s3_url(object.featured_image)
  end

  def hero_image
    filepicker_to_s3_url(object.image_id)
  end

  def url
    activity_url(object)
  end

  def used_in
    activities = object.used_in_activities.chefsteps_generated.published
    ActiveModel::ArraySerializer.new(activities, each_serializer: Api::ActivityIndexSerializer)
  end

  def chefsteps_generated
    object.chefsteps_generated
  end

  def title
    CGI.unescapeHTML(object.title.to_s)
  end

  def description
    CGI.unescapeHTML(object.description.to_s)
    end

  def short_description
    CGI.unescapeHTML(object.short_description.to_s)
  end

  def byline
    CGI.unescapeHTML(object.byline.to_s)
  end

end
