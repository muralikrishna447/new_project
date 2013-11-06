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

  $('.enrollment-wizard').each ->
    enroll_section = $(this).find('.enroll-section')
    signup_or_signin_section = $(this).find('.signup-or-signin-section')
    signup_and_enroll_section = $(this).find('.signup-and-enroll-section')
    signin_and_enroll_section = $(this).find('.signin-and-enroll-section')
    browse_section = $(this).find('.browse-section')
    enroll_section.show()
    enroll_section_btn = enroll_section.find('.enroll-section-btn')
    signup_and_enroll_btn = signup_or_signin_section.find('.signup-and-enroll-btn')
    signin_and_enroll_btn = signup_or_signin_section.find('.signin-and-enroll-btn')
    enroll_section_btn.click ->
      enroll_section.hide()
      signup_or_signin_section.show()
      browse_section.hide()

      signup_and_enroll_btn.click ->
        signup_or_signin_section.hide()
        signup_and_enroll_section.show()
        enrollment_method: 'New User'

      signin_and_enroll_btn.click ->
        signup_or_signin_section.hide()
        signin_and_enroll_section.show()
        enrollment_method: 'Standard'


  #### HACK FOR ANCHOR TAGS ####
  current_url = document.URL
  pattern = /#/g
  if pattern.test(current_url)
    string1 = String(current_url.split('?')[0].match(/#.*/))
    string2 = string1.replace('/', '')
    if $(string2).length > 0
      $('html, body').animate({scrollTop:$(string2).position().top - 130}, 'slow')
