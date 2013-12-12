# # ActiveAdmin.register Course do
#   config.sort_order = 'course_order_asc'

#   menu priority: 2

#   action_item only: [:index] do
#     link_to('Order Courses', courses_order_admin_courses_path)
#   end

#   action_item only: [:show, :edit] do
#     link_to_publishable course, 'View on Site'
#   end

#   show do |course|
#     render "show", course: course
#   end

#   form partial: 'form'

#   index do
#     column 'Link' do |course|
#       link_to_publishable(course)
#     end
#     column :title, sortable: :title do |course|
#       course.title.html_safe
#     end
#     column "Description" do |course|
#       truncate(course.description, length: 50)
#     end
#     column :published
#     default_actions
#   end

#   controller do
#     def extract_activity_hierarchy
#       activities = JSON.parse(params[:activity_hierarchy])
#     end

#     def create
#       activity_hierarchy = extract_activity_hierarchy
#       @course = Course.create(params[:course])
#       @course.update_activities(activity_hierarchy)
#       create!
#       logger.info "**** Created Course" + params[:activity_hierarchy]
#     end

#     def update
#       activity_hierarchy = extract_activity_hierarchy
#       @course = Course.find(params[:id])
#       @course.update_activities(activity_hierarchy)
#       update!
#       logger.info "**** Updated Course" + params[:activity_hierarchy]
#     end

#     private
#   end

#   collection_action :courses_order, method: :get do
#     @courses = Course.ordered.all
#   end

#   collection_action :update_courses_order, method: :post do
#     params[:course_ids].each do |course_id|
#       course = Course.find(course_id)
#       if course
#         course.course_order_position = :last
#         course.save!
#       end
#     end

#     redirect_to({action: :index}, notice: "Course order has been updated")
#   end
# end

