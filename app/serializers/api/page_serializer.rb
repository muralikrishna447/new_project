class Api::PageSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :short_description, :is_promotion, :discount_id, :redirect_path
  has_many :components, serializer: Api::ComponentSerializer

end
