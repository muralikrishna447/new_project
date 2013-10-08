affixElement = ->
  affix = $('.cs-affix')
  affix_offset = affix.data('offset-top')
  window_width = window.innerWidth
  console.log window_width
  if window_width < 979
    if $(window).scrollTop() >= affix_offset
      affix.css('position', 'fixed')
      affix.css('top', '0px')
    else
      affix.css('position', 'absolute')
      affix.css('top', '56px')
  else
    if $(window).scrollTop() >= affix_offset
      affix.css('position', 'fixed')
      affix.css('top', '56px')
    else
      affix.css('position', 'fixed')
      affix.css('top', '56px')
    
$ ->
  $(window).hammer({drag_min_distance: 1}).on 'drag', (e) ->
    affixElement()
    e.preventDefault()

  $(window).hammer().on 'swipe', (e) ->
    affixElement()
    e.preventDefault()

  $(window).hammer().on 'scroll', (e) ->
    affixElement()

  $(window).resize ->
    affixElement()

  $('#cs-navigation').on 'show', ->
    $('.course-nav-wrapper').hide()
    $('#step-dots').hide()

  $('#cs-navigation').on 'hide', ->
    $('.course-nav-wrapper').show()
    $('#step-dots').show()