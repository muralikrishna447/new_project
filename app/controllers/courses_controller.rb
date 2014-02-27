class CoursesController < ApplicationController

  def index
    pubbed_assembly_courses = Assembly.pubbed_courses.order('created_at asc')
    prereg_assembly_courses = Assembly.prereg_courses.order('created_at asc')
    @assembly_courses = prereg_assembly_courses | pubbed_assembly_courses
  end

end

