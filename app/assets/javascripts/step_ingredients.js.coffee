$ ->

  $('.step-image-btn').click ->
    image = $(this).closest('.step-content').find('.step-image')
    $('.step-image').each ->
      if $(this).attr('id') != image.attr('id') && $(this).css('display') == 'block'
        $(this).toggle('blind', 300)
    image.toggle('blind', 300)

  $('.step-video-btn').click ->
    video = $(this).closest('.step-content').find('.step-video')
    $('.step-video').each ->
      if $(this).attr('id') != video.attr('id') && $(this).css('display') == 'block'
        $(this).toggle('blind', 300)
    video.toggle('blind', 300)
