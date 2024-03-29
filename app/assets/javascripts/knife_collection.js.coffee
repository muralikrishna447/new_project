# Putting this back in because the SV Collection relies on it.  
# I know this is old horrible code, but until we decide to update the SV collection page we'll need to keep this around.

$ -> 
  if $('.knife').is('*')
    $('.modal a').click (e) ->
      e.preventDefault()
      $(this).closest('.modal-body').children('img').hide()
      idx = $(this).parent().index()
      $($(this).closest('.modal-body').children('img')[idx]).removeClass('hidden').fadeIn()

    console.log 'KNIFE LOADEDZZ'
    window_width = window.outerWidth
    console.log window_width 
    $(window).scroll ->
      if $(window).scrollTop() <= 60
        if window_width > 767
          $('#knife-intro').fadeIn 'fast', 'easeInOutQuad'
        $('.knife').removeClass 'alt'
      else
        if window_width > 767 
          $('#knife-intro').fadeOut 'fast','easeInOutQuad' 
        $('.knife').addClass 'alt'


# Annotation Sliders #

annotationSlide = (slider, button, direction) ->
  slider_parent = slider.closest('.annotation-slider-container')
  slider_height = slider.outerHeight()
  notes = slider.find('.annotation-slider-note')
  note_width = slider.find('.annotation-slider-note').outerWidth() + 10

  heights = []
  notes.each ->
    heights.push($(this).outerHeight())

  note_height = Math.max.apply(Math,heights)

  if direction == 'left'
    slider.css 'left', Math.abs(note_width)
  else if direction == 'center'
    center = slider.find('.note-center')
    center_image = slider.find('.annotation-slider-image-center img')
    center_image.css 'opacity', 0
    center.css 'opacity', 1
    center_image.css 'pointer-events', 'none'
    center.css 'pointer-events', 'auto'

  else
    slider.css 'left', -1*Math.abs(note_width)

  if note_height > slider_height
    slider_parent.css 'height', note_height
  button.addClass('annotation-slider-btn-close')
  slider.find('.annotation-close-overlay').show()

annotationClose = (slider) ->
  slider_parent = slider.closest('.annotation-slider-container')
  slider_height = slider.outerHeight()
  notes = slider.find('.annotation-slider-note')
  slider_buttons = slider.find('.annotation-slider-btn')
  heights = []
  notes.each ->
    heights.push($(this).outerHeight())

  note_height = Math.max.apply(Math,heights)

  if note_height > slider_height
    slider_parent.css 'height', slider_height

  slider.css 'left', '0'
  slider_buttons.removeClass('annotation-slider-btn-close')

  center = slider.find('.note-center')
  center_image = slider.find('.annotation-slider-image-center img')
  center_image.css 'opacity', 1
  center.css 'opacity', 0
  center_image.css 'pointer-events', 'auto'
  center.css 'pointer-events', 'none'

$ ->
  if $('.knife').is('*')
    $('.annotation-slider-container').each ->
      slider = $(this).find('.annotation-slider')
      overlay = slider.find('.annotation-close-overlay')
      slider.find('.annotation-slider-btn').each ->
        button = $(this)
        button.click ->
          direction = button.data('annotation-slider-reveal')
          annotationSlide(slider, button, direction)

      slider.find('.annotation-close-btn').each ->
        close_button = $(this)
        close_button.click ->
          annotationClose(slider)
          overlay.hide()

      overlay.click ->
        annotationClose(slider)
        overlay.hide()

    $('.annotation-slider-note-gallery').each ->
      gallery = $(this)
      images = gallery.find('.annotation-slider-note-gallery-images')
      thumbnails = gallery.find('.annotation-slider-note-gallery-thumbnail')
      thumbnails.each (thumbnail_index) ->
        thumbnail = $(this)
        thumbnail.click ->
          console.log thumbnail_index
          console.log images[0]
          images.find('.annotation-slider-note-gallery-image').each (image_index) ->
            if thumbnail_index == image_index
              console.log 'show ' + image_index
              $(this).css 'opacity', 1
            else
              console.log 'hide ' + image_index
              $(this).css 'opacity', 0
