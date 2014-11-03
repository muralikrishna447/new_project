class Api::ActivityEquipmentSerializer < ApplicationSerializer
  attributes :order, :optional

  has_one :equipment, serializer: EquipmentIndexSerializer

  def order
    object.equipment_order
  end
end
