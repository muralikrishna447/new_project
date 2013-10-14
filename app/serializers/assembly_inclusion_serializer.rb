class AssemblyInclusionSerializer < ActiveModel::Serializer
  attributes :includable_type, :includable_id, :position, :includable_title, :include_disqus, :includable_slug
  has_one :includable

  def includable_title
    object.includable.title
  end

  def includable_slug
    object.includable.slug
  end

  # This picks up the recursive tree of associations
  def include_associations!
    include! :includable if object.includable_type == "Assembly"
  end

end
