class AssemblyInclusionSerializer < ApplicationSerializer
  attributes :includable_type, :includable_id, :position, :includable_title, :include_disqus, :includable_description, :includable_slug, :assembly_id, :includable_disqus_id, :includable_always_include_disqus, :includable_image_id
  has_one :includable

  def includable_title
    object.includable.title
  end

  def includable_description
    if object.includable.class.method_defined?(:description)
      object.includable.description
    end
  end

  def includable_slug
    object.includable.slug
  end

  def includable_disqus_id
    if object.includable.class.method_defined?(:disqus_id)
      object.includable.disqus_id
    end
  end

  def includable_always_include_disqus
    if object.includable.class.method_defined?(:always_include_disqus)
      object.includable.always_include_disqus
    end
  end

  def includable_image_id
    if object.includable.class.method_defined?(:image_id)
      object.includable.image_id
    end
  end

  # This picks up the recursive tree of associations, and also page controller content.
  # Might not be a bad idea at all to just send activities too, it isn't like it is a lot of data.
  def include_associations!
    include! :includable if ["Assembly", "Page"].include?(object.includable_type)
  end

end
