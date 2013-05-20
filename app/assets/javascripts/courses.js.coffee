$ ->
  if $('.course_activity_content').is('*')
    expandSteps()

  $('.nav-expand-link').click ->
    parent_id = $(this).parent('li').data('inclusion-id')
    $("[data-parent='inclusion-id-" + parent_id + "']").each ->
      $(this).toggle()

  show_password_index = 0
  $('#user-password-show').click ->
    user_password_field = $('#user_password')
    if ++show_password_index % 2
      user_password_field.attr 'type', 'text'
    else
      user_password_field.attr 'type', 'password'

  # i = 0
  # $('.course-nav-top-prev').click ->
  #   navbar = $('#course-navbar-top')
  #   toggle_button = $(this)
  #   hidden_items = navbar.find('.hide-course-navbar-item')
  #   if hidden_items.length == 0
  #     navbar.find('.show-course-navbar-item').each ->
  #       $(this).addClass 'hide-course-navbar-item'
  #       $(this).removeClass 'show-course-navbar-item', 200, 'easeInQuad'
  #     toggle_button.find('i').attr 'class', 'icon-chevron-left'
  #   else
  #     last_hidden = hidden_items.last()
  #     last_hidden.addClass 'show-course-navbar-item', 200, 'easeInQuad'
  #     last_hidden.removeClass 'hide-course-navbar-item'
  #   if hidden_items.length == 1
  #     toggle_button.find('i').attr 'class', 'icon-chevron-right'