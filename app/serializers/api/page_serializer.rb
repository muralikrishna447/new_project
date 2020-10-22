class Api::PageSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :short_description, :is_promotion, :discount_id, :redirect_path, :featured_image_url, :userCount
  has_many :components, serializer: Api::ComponentSerializer

  def userCount
    User.fetchCount
  end

end
