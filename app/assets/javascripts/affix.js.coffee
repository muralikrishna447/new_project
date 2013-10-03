affixElement = ->
  affix = $('.cs-affix')
  affix_offset = affix.data('offset-top')
  if $(window).scrollTop() >= affix_offset
    affix.css('position', 'fixed')
    affix.css('top', '0px')
  else
    affix.css('position', 'absolute')
    affix.css('top', '0px')

setNavbar = ->
  if $(window).width() < 979 && $(window).scrollTop() >= 56
    $('.navbar-fixed-top').css('top', '-56')
  else
    $('.navbar-fixed-top').css('top', '0')
    
$ ->
  $(window).hammer().on 'drag', (e) ->
    affixElement()
    setNavbar()

  $(window).hammer().on 'swipe', (e) ->
    affixElement()
    setNavbar()

  $(window).on 'scroll', (e) ->
    affixElement()
    setNavbar()