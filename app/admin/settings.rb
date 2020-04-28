ActiveAdmin.register Setting do
  menu priority: 3
  permit_params :footer_image, :premium_membership_price

  form :partial => "form"

  index do
    id_column
    actions
  end

  show do
    attributes_table do
      row :premium_membership_price
    end
  end

end