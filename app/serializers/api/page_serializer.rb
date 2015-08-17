class Api::PageSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title
  has_many :components, serializer: Api::ComponentSerializer

end
