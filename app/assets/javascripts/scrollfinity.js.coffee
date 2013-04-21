initScrollfinity = (scrollable) ->
  addTopElement(scrollable)

addTopElement = (scrollable) ->
  # Get the first and last element
  first = scrollable.find(">:first-child")
  last = scrollable.find(">:last-child")

  # Add it to the top
  last.prependTo(scrollable)

  # Prevent Scrolling
  previous_height = 0
  first.prevAll().each ->
    previous_height += $(this).outerHeight()
  scrollable.scrollTop(previous_height)

addBottomElement = (scrollable) ->
  # Get the first and last element
  first = scrollable.find(">:first-child")
  last = scrollable.find(">:last-child")

  # Add it to the top
  first.appendTo(scrollable)

  # Prevent Scrolling
  previous_height = 0
  first.prevAll().each ->
    previous_height += $(this).outerHeight()
  scrollable.scrollTop(previous_height - scrollable.height())

is_touch_device = ->
  # works on most browsers 
  !!("ontouchstart" of window) or !!("onmsgesturechange" of window) # works on ie10

$ ->
  # Touch device detection
  if is_touch_device()
    $('.only-non-touch').hide()
    $('.only-touch').each ->
      $(this).show()
  else
    $('.only-touch').hide()

  $('.scrollfinity').each ->
    scrollable = $(this)
    initScrollfinity(scrollable)

    total_height = 0
    scrollable.children().each ->
      total_height += $(this).outerHeight()
    window_height = scrollable.height()
    scrollable.scroll ->
      scroll_top = scrollable.scrollTop()
      scroll_bottom = total_height - window_height - scroll_top
      if scroll_top == 0
        addTopElement(scrollable)
      if scroll_bottom == 0
        addBottomElement(scrollable)

  $('.scrollfinity-down').click ->
    button = $(this)
    scrollable = button.prev('.scrollfinity')
    height = scrollable.children().first().outerHeight()
    if (!scrollable.is(":animated"))
      scrollable.animate
        scrollTop: scrollable.scrollTop() + height
      , 300