ActiveAdmin.register Video do
  menu priority: 3

  form do |f|
    f.inputs "Video" do
      f.input :youtube_id, label:'Youtube ID'
      f.input :title
      f.input :description
      f.input :featured
      f.input :filmstrip
    end

    f.buttons
  end
end

