class CoursesController < ApplicationController
  include VideoHelper
  expose(:activities) { Activity.all }
end

