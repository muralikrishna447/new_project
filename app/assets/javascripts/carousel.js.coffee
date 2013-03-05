$ ->
  $('#myCarousel').each (_, carousel) ->
    $(carousel).carousel()

  $('.carousel-scroll').each ->
    inner = $(this).find('.carousel-scroll-inner')
    item_count = $(this).find('.carousel-scroll-inner .item').size()
    item_width = $(this).find('.item').width()
    total_width = item_width*item_count

    inner.css 'width', total_width
    $(this).find('.carousel-scroll-inner .item').each (index, element) =>
      $(element).delay(500*index).fadeIn(1000)
