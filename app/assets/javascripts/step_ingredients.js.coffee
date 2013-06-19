$ ->

  # Would be nice to move this into angular, but by delegating the events from the
  # document it was easy to keep working this way, so left it for now.
  $(document).on "click", ".step-image-btn", ->
    image = $(this).closest('.step-content').find('.step-image')
    $('.step-image').each ->
      if $(this).attr('id') != image.attr('id') && $(this).css('display') == 'block'
        $(this).toggle('blind', 300)
    image.toggle('blind', 300)

  $(document).on "click", ".step-video-btn", ->
    video = $(this).closest('.step-content').find('.step-video')
    $('.step-video').each ->
      if $(this).attr('id') != video.attr('id') && $(this).css('display') == 'block'
        $(this).toggle('blind', 300)
    video.toggle('blind', 300)
