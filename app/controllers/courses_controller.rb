class CoursesController < ApplicationController
  def index
    @pubbed_courses = Assembly.pubbed_courses.order('created_at desc')
    @prereg_courses = Assembly.prereg_courses.order('created_at desc')
    @assembly_courses = @pubbed_courses | @prereg_courses
  end
end

