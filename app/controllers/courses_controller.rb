class CoursesController < ApplicationController
  include ApplicationHelper
  expose(:activities) { Activity.all }

  def show
    @video_url = build_video_url("Urd5P3yfLZo")
  end
end

