class ContentStepSerializer < ApplicationSerializer
  attributes :id, :title, :image, :description, :url, :context

  def image
    filepicker_arbitrary_image(object.image_id, 400)
  end

  def url
    activity_url(object.activity)
  end

  def context
    'Step'
  end
end