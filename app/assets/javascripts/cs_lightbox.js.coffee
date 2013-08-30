openLightbox = (lightbox, url) ->
  lightbox.fadeIn()
  image_container = lightbox.find('.cs-lightbox-image')
  image_container.html("<img src='" + url + "'/>")
  image_width = image_container.width()
  image_height = image_container.height()
  window_height = window.innerHeight
  console.log window_height
  # image_container.find('img').height('100px')
  if image_height > (window_height - 40)
    new_height = window_height - 40
    new_width = (image_width*new_height)/image_height
    image_container.height(new_height)
    image_container.width(new_width)

closeLightbox = (lightbox) ->
  lightbox.fadeOut 'fast', ->
    image_container = lightbox.find('.cs-lightbox-image')
    image_container.html()
    image_container.width('inherit')
    image_container.height('inherit')

$ ->
  lightbox = $('.cs-lightbox')
  $('.open-lightbox').click ->
    trigger = $(this)
    url = trigger.data('url')
    openLightbox(lightbox, url)

  $('.cs-lightbox-overlay').click ->
    closeLightbox(lightbox)