class Api::EquipmentIndexSerializer < ActiveModel::Serializer
  attributes :id, :title, :url, :productUrl

  def url
    equipment_url(object)
  end

  def productUrl
    object.product_url
  end
end
