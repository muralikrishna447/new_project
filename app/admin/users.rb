ActiveAdmin.register User do
  menu parent: 'More'

  action_item only: [:show] do
    link_to('Send Password Reset Email', reset_password_admin_user_path(user), method: :post, confirm: 'Are you sure?')
  end

  member_action :reset_password, method: :post do
    @user = User.find(params[:id])
    email = @user.email
    User.send_reset_password_instructions({email: email})
    redirect_to({action: :show}, notice: "Password reset email has been sent to #{email}")
  end

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
    f.actions
  end
end

