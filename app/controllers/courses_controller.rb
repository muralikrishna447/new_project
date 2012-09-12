class CoursesController < ApplicationController
  include AggressiveCaching
  expose(:activities) { Activity.all }
end

