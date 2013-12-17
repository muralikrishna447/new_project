class CoursesController < ApplicationController

  def index
    @courses = Course.published.order('updated_at desc')
    pubbed_assembly_courses = Assembly.pubbed_courses.order('updated_at desc')
    prereg_assembly_courses = Assembly.prereg_courses.order('updated_at desc')
    @assembly_courses = prereg_assembly_courses | pubbed_assembly_courses
  end

end

