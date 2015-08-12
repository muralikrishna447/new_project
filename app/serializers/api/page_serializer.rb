class Api::PageSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title
end
