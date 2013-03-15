adjustStepHeight = () ->
  height = $('#video-ingredient-unit').height()
  $('.ordered-steps').css 'height', height

$ ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight() 

  i = 0
  $('#show-all').click ->
    if ++i % 2
      $('.ordered-steps').height 'inherit'
      $('.step-image').each ->
        $(this).show 'blind', {direction: 'vertical'}, 500
      $('.step-ingredients-source').each ->
        $(this).show 'blind', {direction: 'vertical'}, 500
      $('.step-actions').each ->
        $(this).hide 'blind', {direction: 'vertical'}, 500
      $('.scroll-overlay-top').hide()
      $('.scroll-overlay-bottom').hide()
    else
      $('.ordered-steps').height height
      $('.step-image').each ->
        $(this).hide 'blind', {direction: 'vertical'}, 500
      $('.step-ingredients-source').each ->
        $(this).hide 'blind', {direction: 'vertical'}, 500
      $('.step-actions').each ->
        $(this).show 'blind', {direction: 'vertical'}, 500
      $('.scroll-overlay-bottom').show()

  $('.social-action').each ->
    $(this).popover()

  $('.syllabus-popover').each ->
    $(this).popover()