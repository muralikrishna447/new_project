ActiveAdmin.register Setting, as: 'Site Settings' do
  menu priority: 3

  form do |f|
    f.inputs "Setting" do
      f.input :footer_image
    end

    f.buttons
  end
end