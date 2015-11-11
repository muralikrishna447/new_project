class Api::PageSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :short_description
  has_many :components, serializer: Api::ComponentSerializer

end
