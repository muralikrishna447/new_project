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

$ ->
  $('.scrollfinity').each ->
    scrollable = $(this)

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
