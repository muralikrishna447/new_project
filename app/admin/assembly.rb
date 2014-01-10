ActiveAdmin.register Assembly do
  menu parent: 'Assemblies'
  form :partial => "form"

  # Removing this for now b/c it is broken for courses (needs to be classes), and meaningless for groups
=begin
  action_item only: [:show, :edit] do
    # link_to_publishable assembly, 'View on Site'
    link_to 'View on Site', "/#{assembly.assembly_type.downcase.pluralize}/#{assembly.slug}", target: 'blank'
  end
=end

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
    default_actions
  end

  show do
    render 'show', assembly: assembly
  end

end