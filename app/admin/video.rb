ActiveAdmin.register Video, as: 'Home Page Videos' do
  menu priority: 3

  form do |f|
    f.inputs "Video" do
      f.input :title
      f.input :youtube_id, label:'Youtube ID'
      f.input :image_id
      f.input :description
      f.input :featured
      f.input :filmstrip
    end

    f.buttons
  end
end

