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

annotationSlide = (slider, direction) ->
  slider_parent = slider.closest('.annotation-slider-container')
  slider_height = slider.outerHeight()
  notes = slider.find('.annotation-slider-note')
  note_width = slider.find('.annotation-slider-note').outerWidth() + 10

  heights = []
  notes.each ->
    heights.push($(this).outerHeight())

  note_height = Math.max.apply(Math,heights)
  console.log note_height

  if direction == 'left'
    slider.css 'left', note_width
  else
    slider.css 'left', '-' + note_width

  if note_height > slider_height
    slider_parent.css 'height', note_height

  slider.find('.annotation-close-overlay').show()

annotationClose = (slider) ->
  slider_parent = slider.closest('.annotation-slider-container')
  slider_height = slider.outerHeight()
  notes = slider.find('.annotation-slider-note')
  heights = []
  notes.each ->
    heights.push($(this).outerHeight())

  note_height = Math.max.apply(Math,heights)

  if note_height > slider_height
    slider_parent.css 'height', slider_height

  slider.css 'left', '0'


$ ->
  $('.annotation-slider-container').each ->
    slider = $(this).find('.annotation-slider')
    overlay = slider.find('.annotation-close-overlay')
    slider.find('.annotation-slider-btn').each ->
      button = $(this)
      button.click ->
        direction = button.data('annotation-slider-reveal')
        annotationSlide(slider, direction)

    slider.find('.annotation-close-btn').each ->
      close_button = $(this)
      close_button.click ->
        annotationClose(slider)
        overlay.hide()

    overlay.click ->
      annotationClose(slider)
      overlay.hide()