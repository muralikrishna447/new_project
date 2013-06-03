ActiveAdmin.register Upload do

index do
  column :image do |upload|
    image_tag filepicker_media_box_image(upload.image_id)
  end
  column :user do |upload|
    link_to upload.user.email, admin_user_path(upload.user)
  end
  column :action do |upload|
    if upload.approved?
      link_to 'Unapprove', edit_admin_upload_path(upload)
    else
      link_to 'Approve', edit_admin_upload_path(upload)
    end
  end
end

end