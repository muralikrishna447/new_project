ActiveAdmin.register Step do
  form do |f|
    f.inputs "Step Details" do
      f.input :title
      f.input :youtube_id
      f.input :directions
      f.input :image_id
    end

    f.inputs "Ingredients" do
      f.input :ingredients
    end

    f.buttons
  end
end

