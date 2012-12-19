ActiveAdmin.register Course do
  config.sort_order = 'course_order_asc'

  menu priority: 2

  action_item only: [:index] do
    link_to('Order Courses', courses_order_admin_courses_path)
  end

  action_item only: [:show, :edit] do
    link_to_publishable course, 'View on Site'
  end

  show do |course|
    render "show", course: course
  end

  form partial: 'form'

  index do
    column 'Link' do |course|
      link_to_publishable(course)
    end
    column :title, sortable: :title do |course|
      course.title.html_safe
    end
    column "Description" do |course|
      truncate(activity.description, length: 50)
    end
    column :published
    default_actions
  end

  controller do
    def create
      @activity = Activity.create(params[:course])
      create!
    end

    def update
      course = Activity.find(params[:id])
      update!
    end

    private
  end

  collection_action :courses_order, method: :get do
    @activities = Course.ordered.all
  end

  collection_action :update_courses_order, method: :post do
    params[:course_ids].each do |course_id|
      course = Activity.find(course_id)
      if course
        course.course_order_position = :last
        course.save!
      end
    end

    redirect_to({action: :index}, notice: "Course order has been updated")
  end
end

