ActiveAdmin.register Activity do

  show do |activity|
    render "show", activity: activity
  end

  form partial: 'form'

  index do
    column "Order", :activity_order
    column :title
    column :difficulty
    column :yield
    column "Description" do |activity|
      truncate(activity.description, length: 50)
    end
    default_actions
  end

  controller do
    def create
      @activity = Activity.create(params[:activity])
      @activity.update_equipment(separate_equipment)
      create!
    end

    def update
      @activity = Activity.find(params[:id])
      @activity.update_equipment(separate_equipment)
      update!
    end

    private

    def separate_equipment
      params[:activity].delete(:equipment)
    end
  end
end

