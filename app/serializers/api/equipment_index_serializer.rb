class Api::EquipmentIndexSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :title, :url, :product_url

  def url
    equipment_url(object)
  end

end
