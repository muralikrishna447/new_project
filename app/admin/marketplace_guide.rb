ActiveAdmin.register MarketplaceGuide do
  permit_params :guide_id, :url, :button_text, :button_text_line_2, :feature_name
  form partial: 'form'

  index do
    column :guide_id
    column :url
    column :button_text
    column :button_text_line_2
    actions
  end

end