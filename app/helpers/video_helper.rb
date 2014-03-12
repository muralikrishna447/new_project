module VideoHelper
  def youtube_url(youtube_id, autoplay=0)
    "//www.youtube.com/embed/#{youtube_id}?wmode=opaque&rel=0&modestbranding=1&showinfo=0&autoplay=#{autoplay}&iv_load_policy=3"
  end

  def youtube_image(youtube_id,thumbnail=0)
  	"//img.youtube.com/vi/#{youtube_id}/#{thumbnail}.jpg"
  end
end

