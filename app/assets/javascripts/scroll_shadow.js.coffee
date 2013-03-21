setOverlay = (scrollable, top_hidden, bottom_hidden) ->
  if top_hidden > 0
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-top').show()
  else
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-top').hide()

  if bottom_hidden > 50
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-bottom').show()
  else
    scrollable.closest('.scroll-shadow-wrapper').find('.scroll-overlay-bottom').hide()

$ ->
  $('.scroll-shadow').each ->
    scrollable = $(this)
    total_height = scrollable.find('.scroll-shadow-content').height()
    window_height = $(this).height()
    top_hidden = $(this).scrollTop() # Height of the hidden content at the top of the scrollable element
    bottom_hidden = total_height - window_height - top_hidden # Height of the hidden content at the bottom of the scrollable element
    setOverlay(scrollable, top_hidden, bottom_hidden) # Sets the overlay when the page loads

    scrollable.scroll ->
      top_hidden = $(this).scrollTop()
      bottom_hidden = total_height - window_height - top_hidden
      setOverlay(scrollable, top_hidden, bottom_hidden)