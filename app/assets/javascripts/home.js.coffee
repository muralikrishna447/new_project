$ ->
  video_container = $('#hero-video').find('.video-container')
  first_youtube_id = $('#hero-first').find('.media-hero-play').data('youtubeid')
  player = new YT.Player 'hero-player', {
    videoId: first_youtube_id,
    playerVars: { 'modestbranding': 1, 'showinfo': 0 }
  }

  $('#hero-carousel').carousel({
    interval: 8000
  })

  $('#hero-carousel').bind 'slid', ->
    youtube_id = $(this).find('.active').find('.media-hero-play').data('youtubeid')
    player.cueVideoById(youtube_id)

  $('.media-hero-play').click ->
    $('#hero-carousel').carousel('pause')
    youtube_id = $(this).find('.media-hero-play').data('youtubeid')
    $('#hero-container').fadeOut 1000
    player.playVideo()
    # video_container.fadeIn 1000

  $('#recipe-carousel').carousel({
    interval: false
  })

  $('#player-close').click ->
    player.stopVideo()
    $('#hero-container').fadeIn 1000
    $('#hero-carousel').carousel('cycle')