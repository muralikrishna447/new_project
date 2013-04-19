$ ->
  $('.horizontal-swiper').each ->
    swiper = $(this)
    window.recipeSwipe = Swipe(swiper[0],{
      stopPropagation: true,
      continuous: true
      })

    direction = swiper.data('direction')
    if direction == 'right'
      swiper.append("<div class='btn btn-circle horizontal-swiper-btn-right'><i class='icon-chevron-right'></i></div>")
