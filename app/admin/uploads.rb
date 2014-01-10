ActiveAdmin.register Upload do
menu parent: 'Engagement'
scope :approved
scope :unapproved

member_action :approve, :method => :get do
  upload = Upload.find(params[:id])
  upload.approved = true
  upload.save
  redirect_to admin_uploads_path, notice: 'Approved!'
end

member_action :unapprove, :method => :get do
  upload = Upload.find(params[:id])
  upload.approved = false
  upload.save
  redirect_to admin_uploads_path, notice: 'Unapproved.'
end

index do
  column :image do |upload|
    image_tag filepicker_media_box_image(upload.image_id)
  end
  column :user do |upload|
    link_to upload.user.email, admin_user_path(upload.user)
  end
  column :assembly do |upload|
    if upload.assembly
      link_to upload.assembly.title, assembly_path(upload.assembly)
    end
  end
  column :activity do |upload|
    if upload.activity
      link_to upload.activity.title, activity_path(upload.activity)
    end
  end
  column :action, sortable: :approved do |upload|
    if upload.approved?
      link_to 'Unapprove This', unapprove_admin_upload_path(upload)
    else
      link_to 'Approve This', approve_admin_upload_path(upload)
    end
  end
end

end