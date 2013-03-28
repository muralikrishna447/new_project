$ ->
  $('#myCarousel').each (_, carousel) ->
    $(carousel).carousel()

  $('.carousel-scroll').each ->
    inner = $(this).find('.carousel-scroll-inner')
    item_count = $(this).find('.carousel-scroll-inner .item').size()
    item = $(this).find('.item')
    item_width = item.width()
    item_margin = parseInt(item.css 'margin')
    total_width = (item_width + 2*item_margin)*item_count

    inner.css 'width', total_width
    $(this).find('.carousel-scroll-inner .item').each (index, element) =>
      $(element).delay(500*index).fadeIn(1000)
