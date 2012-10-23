ActiveAdmin.register Activity do

  show do |activity|
    render "show", activity: activity
  end

  form do |f|
    f.inputs "Activity Details" do
      f.input :title
      f.input :description
      f.input :youtube_id
      f.input :yield
      f.input :timing
      f.input :difficulty
      f.input :activity_order
    end
    f.inputs "Equipment" do
      f.input :equipment
    end
    f.inputs "Steps" do
      f.input :steps
    end
    f.inputs "Recipes" do
      f.input :recipes
    end
    f.buttons
  end

  index do
    column "Order", :activity_order
    column :title
    column :difficulty
    column :yield
    column "Description" do |activity|
      truncate(activity.description, length: 50)
    end
  end
end

