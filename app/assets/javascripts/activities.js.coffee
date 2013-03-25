adjustStepHeight = () ->
  window_width = $(window).width()
  unless window_width <= 767
    height = $('#video-ingredient-unit').height()
    $('.ordered-steps').css 'height', height

$ ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight()

  i = 0
  $('#show-all').click ->
    if ++i % 2
      $('#show-all-icon').attr 'class', 'icon-resize-small'
      $('.ordered-steps').height 'inherit'
      $('.step-image').each ->
        $(this).show 'blind', {direction: 'vertical'}, 500
      $('.step-ingredients-source').each ->
        $(this).show 'blind', {direction: 'vertical'}, 500
      $('.step-video').each ->
        $(this).show 'blind', {direction: 'vertical'}, 500
      $('.step-actions').each ->
        $(this).hide 'blind', {direction: 'vertical'}, 500
      $('.scroll-overlay-top').hide()
      $('.scroll-overlay-bottom').hide()
    else
      $('#show-all-icon').attr 'class', 'icon-resize-full'
      $('.ordered-steps').height height
      $('.step-image').each ->
        $(this).hide 'blind', {direction: 'vertical'}, 500
      $('.step-ingredients-source').each ->
        $(this).hide 'blind', {direction: 'vertical'}, 500
      $('.step-video').each ->
        $(this).hide 'blind', {direction: 'vertical'}, 500
      $('.step-actions').each ->
        $(this).show 'blind', {direction: 'vertical'}, 500
      $('.scroll-overlay-bottom').show()

  $('.social-action').each ->
    $(this).popover()

  $('.syllabus-popover').each ->
    $(this).popover()

  $('#activity-description-maximize').click ->
    $('.activity-description').toggleClass 'maximize-description'