$ ->
  # Hero Swiper
  window.heroSwipe = Swipe(document.getElementById('hero-swiper'),{
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
      window.heroSwipe.slide(index, 300)

  $('.hero-swiper-next').click ->
    window.heroSwipe.next()

  # Content Swiper
  window.mySwipe = Swipe(document.getElementById('swiper'),{
    stopPropagation: true,
    continuous: true,
    transitionEnd: (index, elem) ->
      $('.content-indicator-btn').removeClass 'indicator-active'
      id = '#swipe-indicator-' + index
      $(id).addClass 'indicator-active'
    })

  $('.content-indicator-btn').each ->
    $(this).click ->
      index = $(this).data('slide-to-index')
      window.mySwipe.slide(index, 300)
