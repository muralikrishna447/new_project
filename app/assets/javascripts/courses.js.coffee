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

  enroll_section = $('#enroll-section')
  signup_or_signin_section = $('#signup-or-signin-section')
  signup_and_enroll_section = $('#signup-and-enroll-section')
  signin_and_enroll_section = $('#signin-and-enroll-section')
  browse_section = $('#browse-section')
  enroll_section.show()
  $('#enroll-section-btn').click ->
    enroll_section.hide()
    signup_or_signin_section.show()
    browse_section.hide()

    $('#signup-and-enroll-btn').click ->
      signup_or_signin_section.hide()
      signup_and_enroll_section.show()

    $('#signin-and-enroll-btn').click ->
      signup_or_signin_section.hide()
      signin_and_enroll_section.show()

  #### HACK FOR ANCHOR TAGS ####
  current_url = document.URL
  pattern = /#/g
  if pattern.test(current_url)
    string1 = String(current_url.match(/#\/.+/))
    string2 = string1.replace('/', '')
    $('html, body').animate({scrollTop:$(string2).position().top - 130}, 'slow')
