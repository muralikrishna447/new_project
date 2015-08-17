class Api::ComponentSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :component_type, :meta, :name, :slug, :component_parent_type, :component_parent_id, :position

  def meta
    object.meta
  end
end
