ActiveAdmin.register User do
  actions :all, except: [:destroy]
  menu parent: 'More'
  filter :email
  filter :name
  filter :created_at
  filter :updated_at
  filter :provider
  filter :role
  filter :referred_from

  action_item only: [:show] do
    link_to('Send Password Reset Email', reset_password_admin_user_path(user), method: :post, confirm: 'Are you sure?')
  end

  action_item only: [:show] do
    if user.deleted_at.present?
      link_to('Undelete User', undelete_admin_user_path(user), method: :post, confirm: 'Are you sure?')
    else
      link_to('Soft Delete User', soft_delete_admin_user_path(user), method: :post, confirm: 'Are you sure?')
    end
  end

  member_action :reset_password, method: :post do
    @user = User.find(params[:id])
    email = @user.email
    User.send_reset_password_instructions({email: email})
    redirect_to({action: :show}, notice: "Password reset email has been sent to #{email}")
  end


  member_action :soft_delete, method: :post do
    @user = User.find(params[:id])
    @user.soft_delete
    redirect_to({action: :show}, notice: "User has been deleted")
  end

  member_action :undelete, method: :post do
    @user = User.find(params[:id])
    @user.undelete
    redirect_to({action: :show}, notice: "User has been un-deleted")
  end

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :premium_member
    column :role
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :created_at
  end

  show do |user|
    render "show", user: user
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :name
      f.input :premium_member
      f.input :role, collection: User::ROLES, as: :select
      f.input :location
      f.input :website
      f.input :bio
      f.input :quote
    end
    if f.object.encrypted_password.blank?
      f.inputs "Password (Required!)" do
        f.input :password
        f.input :password_confirmation
      end
    end

    f.actions
  end

  controller do
    with_role :admin
    def max_csv_records
      30_000
    end
  end

  csv do
    column :id
    column :name
    column :email
  end
end

