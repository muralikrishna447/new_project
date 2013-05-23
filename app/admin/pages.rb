ActiveAdmin.register Page do

  form do |f|
    f.inputs 'Pages' do
      f.input :title
      f.input :content
    end
    f.buttons
  end
end