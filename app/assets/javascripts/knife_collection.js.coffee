# $ ->
#   $('.modal a').click (e) ->
#     e.preventDefault()
#     $imgURL = $(this).attr("href")
#     img = $(this).closest('.modal').find('.main-image')
#     img.fadeOut(100, -> 
#       img.attr 'src', $imgURL
#     ).fadeIn 100

$ -> 
  $(window).scroll ->
    if $(window).scrollTop() <= 50
      $('#intro').fadeIn 'fast', 'easeInOutQuad'
      $('.knife').removeClass 'alt'
    else 
      $('#intro').fadeOut 'fast','easeInOutQuad' 
      $('.knife').addClass 'alt'

$ -> 
  $('.modal a').click (e) ->
    e.preventDefault()
    $(this).closest('.modal-body').children('img').hide()
    idx = $(this).parent().index()
    $($(this).closest('.modal-body').children('img')[idx]).removeClass('hidden').fadeIn()


# Annotation Sliders #

$ ->
  $('.annotation-slider-container').each ->
    slider = $(this).find('.annotation-slider')
    slider.find('.annotation-slider-btn').each ->
      button = $(this)
      button.click ->
        direction = button.data('annotation-slider-reveal')
        console.log 'CLICKED' + direction
        if direction == 'left'
          slider.css 'left', '30%'
          # slider.removeClass('annotation-reveal-right')
          # slider.addClass('annotation-reveal-left')
        else
          slider.css 'left', '-30%'
          # slider.removeClass('annotation-reveal-left')
          # slider.addClass('annotation-reveal-right')
    slider.find('.annotation-slider-close').click ->
      slider.css 'left', '0'