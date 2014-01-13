adjustStepHeight = () ->
  window_width = $(window).width()
  unless window_width <= 767
    height = $('#video-ingredient-unit').height()
    $('.ordered-steps').css 'height', height

window.adjustActivityLayout = ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight()


$ ->
  adjustActivityLayout()

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

