class Api::ComponentSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :component_type, :mode, :metadata, :name, :slug

end
