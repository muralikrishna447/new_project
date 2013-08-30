openLightbox = (lightbox, url) ->
  lightbox.fadeIn()
  image_container = lightbox.find('.cs-lightbox-image')
  image = image_container.find('img')
  image.attr('src', url).load ->
    image_width = image_container.width()
    image_height = image_container.height()
    window_height = window.innerHeight
    console.log window_height
    if image_height > (window_height - 40)
      new_height = window_height - 40
      new_width = (image_width*new_height)/image_height
      image_container.height(new_height)
      image_container.width(new_width)

closeLightbox = (lightbox) ->
  image_container = lightbox.find('.cs-lightbox-image')
  image = image_container.find('img')
  lightbox.fadeOut 'fast', ->
    image.attr('src','')
    image_container.width('inherit')
    image_container.height('inherit')

$ ->
  lightbox = $('.cs-lightbox')
  $('.open-lightbox').click ->
    console.log 'clicked'
    trigger = $(this)
    url = trigger.data('url')
    openLightbox(lightbox, url)

  $('.cs-lightbox-overlay').click ->
    closeLightbox(lightbox)

  $('.cs-lightbox-close').click ->
    closeLightbox(lightbox)