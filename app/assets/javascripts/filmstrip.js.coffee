crop_thumbnails = (event) ->
  $('.crop').each ->
    width = $(this).width()
    image = $(this).find('.croppable')
    height = image.height()

    new_height = width*9/16 - 2
    offset_margin = (height - new_height)/2
    $(this).css({
      'height': new_height + 'px',
      'overflow': 'hidden'
    })

    image.css('margin-top', '-' + offset_margin + 'px')

$ ->
  $('.filmstrip-item').click ->
    youtube_id = $(this).data('youtube')
    youtube_url = "http://www.youtube.com/embed/" + youtube_id + "?wmode=opaque&rel=0&modestbranding=1&showinfo=0&vq=hd720&autoplay=1"
    content = "<iframe src='" + youtube_url + "'></iframe"
    video_container = $('.video-container')
    video_container.html(content)

  crop_thumbnails()

$(window).resize ->
  crop_thumbnails()