ActiveAdmin.register User do
  menu parent: 'More'

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :location
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :created_at
    default_actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :name
      f.input :location
      f.input :website
      f.input :quote
    end
    f.inputs "Password" do
      f.input :password
      f.input :password_confirmation
    end
    f.buttons
  end
end

