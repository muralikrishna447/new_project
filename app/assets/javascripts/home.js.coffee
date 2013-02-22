$ ->
  first_youtube_id = $('#hero-first').find('.media-hero-play').data('youtubeid')
  player = new YT.Player 'hero-player', {
    videoId: first_youtube_id,
    playerVars: { 'modestbranding': 1, 'showinfo': 0 }
  }

  $('#hero-carousel').carousel({
    interval: 5000
  })

  $('#hero-carousel').bind 'slid', ->
    youtube_id = $(this).find('.active').find('.media-hero-play').data('youtubeid')
    player.cueVideoById(youtube_id)

  $('.media-hero-play').click ->
    $('#hero-carousel').carousel('pause')
    youtube_id = $(this).find('.media-hero-play').data('youtubeid')
    video = $('#hero-video').find('.video-container')
    video.fadeIn 1000
    player.playVideo()

  $('#recipe-carousel').carousel({
    interval: false
  })

  loadFirstVideo()