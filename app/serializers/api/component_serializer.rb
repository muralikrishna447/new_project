class Api::ComponentSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :component_type, :meta, :name, :slug

  def meta
    object.meta
  end
end
