class Api::ActivityEquipmentSerializer < ActiveModel::Serializer
  attributes :order, :optional

  has_one :equipment, serializer: EquipmentIndexSerializer

  def order
    object.equipment_order
  end
end
