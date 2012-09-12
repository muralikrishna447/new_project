class CoursesController < ApplicationController
  include AggressiveCaching
  include VideoHelper
  expose(:activities) { Activity.all }
end

