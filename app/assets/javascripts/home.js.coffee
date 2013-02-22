$ ->
  $('#hero-carousel').carousel({
    interval: 5000
  })
  $('#recipe-carousel').carousel({
    interval: false
  })

  $('.media-hero-play').click ->
    url = $(this).data('url')
    content = "<iframe src='" + url + "'></iframe>"
    video = $('#hero-video').find('.video-container')
    video.html(content)
    $('#hero-container').animate({
      opacity: 0.5
    }, 1000, ->
      video.fadeIn 500
    )
