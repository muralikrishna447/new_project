adjustStepHeight = () ->
  window_width = $(window).width()
  unless window_width <= 767
    height = $('#video-ingredient-unit').height()
    $('.ordered-steps').css 'height', height

expandSteps = ->
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

collapseSteps = (height) ->
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
  # $('.scroll-overlay-bottom').show()

$ ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight()

  i = 0
  $('#show-all').click ->
    if ++i % 2
      expandSteps()
    else
      collapseSteps(height)
      if $('.ordered-steps').height() >= height
        $('.scroll-overlay-bottom').show()

  $('.social-action').each ->
    $(this).popover()

  $('.syllabus-popover').each ->
    $(this).popover()

  activity_description = $('#activity-description')
  if activity_description.text().length > 455
    $('#activity-description-maximize').show()
  else
    activity_description.find('.activity-description-overlay').hide()

  $('#activity-description-maximize').click ->
    overlay = $(this).closest('.activity-description-wrapper').find('.activity-description-overlay')
    $('.activity-description').toggleClass 'maximize-description', 300, 'easeInCubic'
    if ($(this).text() == 'more')
      $(this).text 'less'
    else
      $(this).text 'more'

$ ->
  $('#editModeButton').button()



$ ->
  $(document).on 'mouseenter', '*[data-wysiwyg]:not(.wysiwyg-active)', ->
    if $('#edit-mode').hasClass('active')
      $(this).addClass('wysiwyg-available')

  $(document).on 'mouseleave', '*[data-wysiwyg]', ->
    $(this).removeClass('wysiwyg-available')

  $(document).on 'click', '.wysiwyg-available', ->
    $.ajax($('#wysiwyg-link').attr('href'), {data: {partialname: $(this).data("wysiwyg") }})
