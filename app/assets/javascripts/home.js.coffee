$ ->
  if $('#hero-video').is('*')
    video_container = $('#hero-video').find('.video-container')
    first_youtube_id = $('#hero-first').find('.media-hero-play').data('youtubeid')
    player = new YT.Player 'hero-player', {
      videoId: first_youtube_id,
      playerVars: { 'modestbranding': 1, 'showinfo': 0, 'rel': 0, 'origin': 'http://www.chefsteps.com', 'vq': 'hd720', 'controls': 1 }
    }

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

  $('#hero-carousel').carousel({
    interval: 8000
  })

  # $('#hero-carousel-indicators li').click ->
  #   $(this).data('')

  $('#recipe-carousel').carousel({
    interval: false
  })

  $('.standalone-tweet').load ->
    alert $(this).html()

  # Helps Prevent the media centered items to load up with black boxes
  $('.media-centered-overlay').show()

  $('#hero-container').hammer().on 'swipeleft', '', (event) ->
    $('#hero-carousel').carousel('next')

  $('#hero-container').hammer().on 'swiperight', '', (event) ->
    $('#hero-carousel').carousel('prev')

  $('#recipe-carousel').hammer().on 'swipeleft', '', (event) ->
    $(this).carousel('next')
    
  $('#recipe-carousel').hammer().on 'swiperight', '', (event) ->
    $(this).carousel('prev')

  window.mySwipe = Swipe(document.getElementById('swiper'),{
    stopPropagation: true,
    continuous: true,
    transitionEnd: (index, elem) ->
      $('.swipe-indicator-btn').removeClass 'indicator-active'
      id = '#swipe-indicator-' + index
      $(id).addClass 'indicator-active'
    })

  $('.swipe-indicator-btn').each ->
    $(this).click ->
      index = $(this).data('slide-to-index')
      window.mySwipe.slide(index, 300)

  window.mySwipe = Swipe(document.getElementById('hero-swiper'),{
    stopPropagation: true,
    continuous: true,
    transitionEnd: (index, elem) ->
      $('.hero-indicator-btn').removeClass 'indicator-active'
      id = '#hero-swipe-indicator-' + index
      $(id).addClass 'indicator-active'
    })

  $('.hero-indicator-btn').each ->
    $(this).click ->
      index = $(this).data('slide-to-index')
      window.mySwipe.slide(index, 300)

