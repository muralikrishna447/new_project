openLightbox = (url) ->
  lightbox = $('.cs-lightbox')
  lightbox.fadeIn()
  lightbox.find('.cs-lightbox-image').html("<img src='" + url + "'/>")
  console.log 'i did it'

$ ->
  $('.open-lightbox').click ->
    trigger = $(this)
    url = trigger.data('url')
    openLightbox(url)