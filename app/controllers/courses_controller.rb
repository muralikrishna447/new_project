class CoursesController < ApplicationController
  expose(:activities) { Activity.all }
end

