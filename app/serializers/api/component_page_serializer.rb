class Api::ComponentPageSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :component_id, :position
end
