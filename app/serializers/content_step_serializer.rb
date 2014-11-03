class ContentStepSerializer < ApplicationSerializer
  attributes :id, :title, :image, :url, :context

  def image
    filepicker_arbitrary_image(object.image_id, 400)
  end

  def url
    "#{activity_url(object.activity)}#numbered-step-#{object.id}"
  end

  def context
    'Step'
  end

  def title
    object.activity.title
  end
end