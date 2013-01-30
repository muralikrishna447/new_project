module VideoHelper
  def youtube_url(youtube_id, autoplay=0)
    "http://www.youtube.com/embed/#{youtube_id}?wmode=opaque&rel=0&modestbranding=1&showinfo=0&vq=hd720&autoplay=#{autoplay}"
  end

  def youtube_image(youtube_id,thumbnail=0)
  	"http://img.youtube.com/vi/#{youtube_id}/#{thumbnail}.jpg"
  end
end

