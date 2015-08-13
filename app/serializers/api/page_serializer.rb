class Api::PageSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :components

  def components
    object.component_pages.map do |component_page|
      Api::ComponentPageSerializer.new component_page, root: false
    end
  end

end
