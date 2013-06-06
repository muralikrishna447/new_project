setOverlay = (scrollable, top_hidden, bottom_hidden) ->
  if top_hidden > 0
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-top').show()
  else
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-top').hide()

  if bottom_hidden > 0
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-bottom').show()
  else
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-bottom').hide()

setOverlayHorizontal = (scrollable, left_hidden, right_hidden) ->
  if left_hidden > 0
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-left').show()
  else
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-left').hide()

  if right_hidden > 0
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-right').show()
  else
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-right').hide()

updateVerticalScrollShadows = (scrollable) ->
  total_height = scrollable.find('.scroll-shadow-content').height()
  window_height = scrollable.height()
  top_hidden = scrollable.scrollTop() # Height of the hidden content at the top of the scrollable element
  bottom_hidden = total_height - window_height - top_hidden # Height of the hidden content at the bottom of the scrollable element
  setOverlay(scrollable, top_hidden, bottom_hidden)

# Sets the overlay when the page loads and whenever scrolled. Timeout to allow angular to setup first.
# Directive would be better.
$ ->
  setTimeout ( ->
    $('.scroll-shadow').each ->
      updateVerticalScrollShadows($(this))
      $(this).scroll ->
        updateVerticalScrollShadows($(this))
  ), 1000

$ ->
  $('.scroll-shadow-horizontal').each ->
    scrollable = $(this)
    total_width = scrollable.find('.scroll-shadow-content').width()
    window_width = $(this).width()
    left_hidden = $(this).scrollLeft()
    right_hidden = total_width - window_width - left_hidden
    setOverlayHorizontal(scrollable, left_hidden, right_hidden)

    scrollable.scroll ->
      left_hidden = $(this).scrollLeft()
      right_hidden = total_width - window_width - left_hidden
      setOverlayHorizontal(scrollable, left_hidden, right_hidden)
