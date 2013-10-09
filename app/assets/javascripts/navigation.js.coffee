affixElement = ->
  $('.cs-affix').each ->
    affix = $(this)
    affix_margin_top = affix.data('margin-top')
    console.log affix_margin_top
    affix_offset = affix.data('offset-top')
    window_width = window.innerWidth
    #console.log window_width

    if window_width < 979
      if $(window).scrollTop() >= affix_offset
        affix.css('position', 'fixed')
        affix.css('top', '0px')
        affix.css('margin-top', affix_margin_top)
      else
        affix.css('position', 'absolute')
        affix.css('top', affix_offset)
    else
      if $(window).scrollTop() >= affix_offset
        affix.css('position', 'fixed')
        affix.css('top', affix_offset)
      else
        affix.css('position', 'fixed')
        affix.css('top', affix_offset)
    
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
    $('.course-nav-slideout').hide()
    $('.course-nav-hamburger').hide()

  $('#cs-navigation').on 'hide', ->
    $('.course-nav-wrapper').show()
    $('#step-dots').show()
    $('.course-nav-slideout').show()
    $('.course-nav-hamburger').show()