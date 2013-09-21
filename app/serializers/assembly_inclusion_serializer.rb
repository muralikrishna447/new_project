class AssemblyInclusionSerializer < ActiveModel::Serializer
  attributes :includable_type, :includable_id, :position, :includable_title

  def includable_title
    object.includable.title
  end

end
