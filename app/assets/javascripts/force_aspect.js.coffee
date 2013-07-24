window.forceAspect = ->
  $('.force-aspect').each ->
    width = $(this).closest('.force-aspect-wrapper').width()
    console.log width
    height = (width * 9.0 / 16.0) + "px"
    console.log height
    $(this).height(height)

$ ->
  window.forceAspect()

  $(window).bind 'resize', ->
    window.forceAspect()