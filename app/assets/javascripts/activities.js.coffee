adjustStepHeight = () ->
  height = $('#video-ingredient-unit').height()
  $('.ordered-steps').css 'height', height

toggleStepImages = () ->
  $('.step-image').each ->
    $(this).toggle('blind', 500)

$ ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight() 

  i = 0
  $('#show-all').click ->
    if ++i % 2
      $('.ordered-steps').height 'inherit'
      toggleStepImages()
    else
      $('.ordered-steps').height height
      toggleStepImages()

  $('.social-action').each ->
    $(this).popover()

  $('.syllabus-popover').each ->
    $(this).popover() 