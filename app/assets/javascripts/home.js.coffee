$ ->
  if $('#hero-video').is('*')
    video_container = $('#hero-video').find('.video-container')
    first_youtube_id = $('#hero-first').find('.media-hero-play').data('youtubeid')
    player = new YT.Player 'hero-player', {
      videoId: first_youtube_id,
      playerVars: { 'modestbranding': 1, 'showinfo': 0, 'rel': 0, 'origin': 'http://www.chefsteps.com', 'vq': 'hd720', 'controls': 1 }
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
      $('#player-close').show()
      player.playVideo()

    $('#player-close').click ->
      player.stopVideo()
      $('#hero-container').fadeIn 1000
      $('#hero-carousel').carousel('cycle')
      $(this).hide()

  $('#recipe-carousel').carousel({
    interval: false
  })

  $('.standalone-tweet').load ->
    alert $(this).html()

  # Helps Prevent the media centered items to load up with black boxes
  $('.media-centered-overlay').show()

