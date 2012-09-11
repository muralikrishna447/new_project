module VideoHelper
  def youtube_url(youtube_id)
    "http://www.youtube.com/embed/#{youtube_id}?rel=0&modestbranding=1&showinfo=0"
  end
end
