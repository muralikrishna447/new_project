ActiveAdmin.register Version do
  menu parent: 'More'

  form do |f|
    f.inputs "Version" do
      f.input :version
    end

    f.buttons
  end

  controller do
    def update
      Version.first.update_attributes(version: Time.now.to_s)
      redirect_to admin_root_path, notice: "Updates published!"
    end
  end
end

