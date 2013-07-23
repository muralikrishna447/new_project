$ ->
  $('.force-aspect').each ->
    width = $(this).closest('.span6').width()
    console.log width
    height = (width * 9.0 / 16.0) + "px"
    console.log height
    $(this).height(height)