module ApplicationHelper

  def build_video_url(id)
    "http://www.youtube.com/embed/#{id}?rel=0&modestbranding=1"
  end
end
