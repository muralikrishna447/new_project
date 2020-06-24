ActiveAdmin.register User do
  actions :all, except: [:destroy]

  permit_params :name, :email, :password, :password_confirmation,
                :remember_me, :location, :quote, :website, :chef_type,
                :from_aweber, :viewed_activities, :signed_up_from, :bio, :image_id,
                :role, :referred_from, :referrer_id, :premium_member,
                :premium_membership_created_at, :premium_membership_price, as: :admin

  before_action :load_user, only: [:show, :edit, :update, :reset_password, :merge, :merge_do,
                                   :soft_delete, :make_premium, :remove_premium, :undelete]

  menu parent: 'More'
  filter :email
  filter :name
  filter :created_at
  filter :updated_at
  filter :provider
  filter :role
  filter :referred_from

  action_item :view, only: [:show] do
    link_to 'Send Password Reset Email', reset_password_admin_user_path(user), method: :post, data: { confirm: 'Are you sure?' }
  end

  action_item :view, only: [:show] do
    if user.deleted_at.present?
      link_to('Undelete User', undelete_admin_user_path(user), method: :post, data: { confirm: 'Are you sure?' })
    else
      link_to('Soft Delete User', soft_delete_admin_user_path(user), method: :post, data: { confirm: 'Are you sure?' })
    end
  end

  action_item :view, only: [:show] do
    unless user.admin?
      if user.premium?
        link_to('Remove premium membership', remove_premium_admin_user_path(user), method: :post)
      else
        link_to('Grant premium membership', make_premium_admin_user_path(user), method: :post)
      end
    end
  end

  action_item :view, only: [:show] do
    link_to('Merge User', merge_admin_user_path(user))
  end

  member_action :reset_password, method: :post do
    logger.info "Admin dashboard: sending password reset email for: #{@user.email}"
    @user.send_password_reset_email
    redirect_to({action: :show}, notice: "Password reset email has been sent to #{@user.email}")
  end

  member_action :soft_delete, method: :post do
    @user.soft_delete
    redirect_to({action: :show}, notice: "User has been deleted")
  end

  member_action :undelete, method: :post do
    @user.undelete
    redirect_to({action: :show}, notice: "User has been un-deleted")
  end

  member_action :remove_premium, method: :post do
    @user.remove_premium_membership
    redirect_to({action: :show}, notice: "User no longer premium member")
  end

  member_action :make_premium, method: :post do
    @user.make_premium_member(0)
    redirect_to({action: :show}, notice: "User is now premium member")
  end

  member_action :merge do
    @page_title = 'Merge User'
  end

  member_action :merge_do, method: :post do
    email = params[:email]
    if email.empty?
      redirect_to({ action: :merge }, alert: 'Oops! Please enter an email address to merge.')
      return
    end

    user_list = User.where(email: email)
    if user_list.empty?
      redirect_to({ action: :merge }, alert: "Sorry! There is no account with the email address #{email}. Try again.")
    else
      begin
        resource.merge(user_list.first)
        redirect_to({ action: :show }, notice: "Success! Account data from #{email} was merged into this account. The account #{email} was soft deleted.")
      rescue ActiveRecord::RecordInvalid => invalid
        redirect_to({ action: :merge }, alert: "Sorry! The user account data is invalid and could not be saved. #{invalid.record.errors.full_messages}")
      end
    end
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
    def max_csv_records
      30_000
    end

    private

    def load_user
      @user = User.friendly.find(params[:id])
    end

  end

  csv do
    column :id
    column :name
    column :email
  end

  after_save do |user|
    Resque.enqueue(Forum, 'update_user', Rails.application.config.shared_config[:bloom][:api_endpoint], user.id)
  end
end
