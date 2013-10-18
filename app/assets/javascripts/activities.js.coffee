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
  # $('.step-ingredients-source').each ->
  #   $(this).show 'blind', {direction: 'vertical'}, 500
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
  # $('.step-ingredients-source').each ->
  #   $(this).hide 'blind', {direction: 'vertical'}, 500
  $('.step-video').each ->
    $(this).hide 'blind', {direction: 'vertical'}, 500
  $('.step-actions').each ->
    $(this).show 'blind', {direction: 'vertical'}, 500
  # $('.scroll-overlay-bottom').show()

window.adjustActivityLayout = ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight()


$ ->
  adjustActivityLayout()

  i = 0
  $('#show-all').click ->
    height = $('#video-ingredient-unit').height()
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

window.setMaximizeDescription = (maximize) ->
  $('.activity-description').toggleClass 'maximize-description', maximize, 300, 'easeInCubic'
  if maximize
    $('#activity-description-maximize').text 'less'
  else
    $('#activity-description-maximize').text 'more'

window.expandSteps = expandSteps
window.collapseSteps = collapseSteps


$ ->
  # User Registration popup shows up after viewing 2 activities
  popup_bottom = $('.popup-bottom')
  if popup_bottom.is('*')
    popup_bottom.delay(5000).addClass 'popup-bottom-show', 1000

    $('.popup-bottom-close').click ->
      popup_bottom.removeClass 'popup-bottom-show', 500


# Prevent browser from changing pages if a user drags in an image and misses a drag target.
# http://stackoverflow.com/questions/7395590/disable-dragging-of-a-file-system-image-into-a-browser
$ ->
  $(window).bind 'dragenter dragover drop', (e) ->
    if ! $(e.target).closest('.drop-target').length
      e.stopPropagation()
      e.preventDefault()
      dt = e.originalEvent.dataTransfer
      if dt
        dt.effectAllowed = dt.dropEffect = "none"

window.cdnURL = (url) ->
  url.replace("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")

