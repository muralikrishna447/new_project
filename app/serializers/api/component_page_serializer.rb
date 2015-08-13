class Api::ComponentPageSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :position
end
