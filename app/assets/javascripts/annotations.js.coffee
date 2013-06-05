$ ->
  # if $('.annotated').is('*')
  #   $(window).scroll ->
  #     window_position = $(window).scrollTop()
  #     $('.annotated').each ->
  #       annotated = $(this)
  #       position = $(this).position()
  #       if position.top - 300 <= window_position < position.top - 50
  #         annotated.addClass 'annotations-show'
  #       else
  #         annotated.removeClass 'annotations-show'

  annotation_previewed = false
  if $('.annotated').is('*')
    if $('.mobile-device').is('*')
      toggle = 0
      $('.annotation-toggle').show()
      $('.annotation-toggle').click ->
        annotated = $(this).prev()
        annotated.toggleClass('annotations-show')
    else
      $(window).scroll ->
        window_position = $(window).scrollTop()
        annotated = $('.annotated-creative')
        position = annotated.position()
        if position.top - 400 < window_position && !annotation_previewed
          annotation_previewed = true
          annotated.addClass('annotations-show').delay(1500).queue ->
            $(this).removeClass('annotations-show')

