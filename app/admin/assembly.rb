ActiveAdmin.register Assembly do
  menu parent: 'Assemblies'

  permit_params :description, :image_id, :prereg_image_id, :title, :youtube_id, :vimeo_id,
                :slug, :assembly_type, :assembly_inclusions_attributes, :badge_id,
                :show_prereg_page_in_index, :short_description, :upload_copy,
                :buy_box_extra_bullets, :preview_copy, :testimonial_copy,
                :prereg_email_list_id, :description_alt, :premium, :published,
                :assembly_inclusions_attributes => [:id, :includable_type, :includable_id,
                                                    :include_disqus, :position, :_destroy]

  form :partial => "form"

  # Removing this for now b/c it is broken for courses (needs to be classes), and meaningless for groups
=begin
  action_item only: [:show, :edit] do
    # link_to_publishable assembly, 'View on Site'
    link_to 'View on Site', "/#{assembly.assembly_type.downcase.pluralize}/#{assembly.slug}", target: 'blank'
  end
=end

 filter :title
 filter :description
 filter :assembly_type
 filter :slug
 filter :created_at
 filter :updated_at
 filter :published
 filter :published_at
 filter :price
 filter :show_prereg_page_in_index
 filter :short_description
 filter :upload_copy
 filter :buy_box_extra_bullets
 filter :preview_copy
 filter :testimonial_copy
 filter :description_alt
 filter :premium


  index do
    column :title, sortable: :title do |activity|
      activity.title.html_safe
    end
    column :assembly_type
    column :slug
    column :price
    column :published
    column :show_prereg_page_in_index
    column "Description" do |assembly|
      truncate(assembly.description, length: 50)
    end
    actions
  end

  show do
    render 'show', assembly: assembly
  end

end