$ ->
  $scroller_anchor = $('[data-behavior~=stick-to-top-anchor]')
  $scroller = $('[data-behavior~=stick-to-top]')

  handler = (e) ->
    anchor_position = $scroller_anchor.offset().top

    if ($(@).scrollTop() > anchor_position and $scroller.css('position') != 'fixed')
      $scroller.addClass('stuck-to-top')
      $scroller_anchor.css('height', $scroller.outerHeight())
    else if ($(@).scrollTop() < anchor_position and $scroller.css('position') != 'relative')
      $scroller_anchor.css('height', '0px')
      $scroller.removeClass('stuck-to-top')

  $(window).scroll _.throttle(handler, 20)
