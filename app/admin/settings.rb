ActiveAdmin.register Setting do
  menu priority: 3

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