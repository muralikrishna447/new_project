ActiveAdmin.register Advertisement do
   form partial: 'form'

  index do
    column :title
    column :description
    column :campaign
    column :url
    default_actions
  end
end
