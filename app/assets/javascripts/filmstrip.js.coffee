$ ->
  $('.filmstrip-item').click ->
    youtube_id = $(this).data('youtube')
    youtube_url = "http://www.youtube.com/embed/" + youtube_id + "?wmode=opaque&rel=0&modestbranding=1&showinfo=0&vq=hd720&autoplay=1"
    content = "<iframe src='" + youtube_url + "'></iframe"
    video_container = $('.video-container')
    video_container.html(content)