ActiveAdmin.register Assembly do
  
  form :partial => "form"

  action_item only: [:show, :edit] do
    # link_to_publishable assembly, 'View on Site'
    link_to 'View on Site', "/#{assembly.assembly_type.downcase.pluralize}/#{assembly.slug}", target: 'blank'
  end

end