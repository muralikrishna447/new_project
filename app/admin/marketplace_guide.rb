ActiveAdmin.register MarketplaceGuide do
  form partial: 'form'

  index do
    column :guide_id
    column :url
    column :button_text
    column :button_text_line_2
    default_actions
  end

end