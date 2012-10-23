ActiveAdmin.register Recipe do

  form do |f|
    f.inputs "Recipe Details" do
      f.input :title
      f.input :activity
      f.input :yield
    end

    f.inputs "Ingredients" do
      f.input :ingredients
    end

    f.inputs "Steps" do
      f.input :steps
    end

    f.buttons
  end
end

