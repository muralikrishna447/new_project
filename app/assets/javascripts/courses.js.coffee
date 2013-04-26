$ ->
  i = 0
  $('.course-nav-top-prev').click ->
    navbar = $('#course-navbar-top')
    toggle_button = $(this)
    hidden_items = navbar.find('.hide-course-navbar-item')
    if hidden_items.length == 0
      navbar.find('.show-course-navbar-item').each ->
        $(this).addClass 'hide-course-navbar-item'
        $(this).removeClass 'show-course-navbar-item', 200, 'easeInQuad'
      toggle_button.find('i').attr 'class', 'icon-chevron-left'
    else
      last_hidden = hidden_items.last()
      last_hidden.addClass 'show-course-navbar-item', 200, 'easeInQuad'
      last_hidden.removeClass 'hide-course-navbar-item'
    if hidden_items.length == 1
      toggle_button.find('i').attr 'class', 'icon-chevron-right'