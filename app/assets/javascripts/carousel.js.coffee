$ ->
  $('#myCarousel').each (_, carousel) ->
    $(carousel).carousel()

  $('.carousel-small').each ->
    inner = $(this).find('.carousel-small-inner')
    item_count = $(this).find('.carousel-small-inner .item').size()
    item_width = $(this).find('.item').width()
    total_width = item_width*item_count

    inner.css 'width', total_width
