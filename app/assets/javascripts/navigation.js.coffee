$ ->

  $('#cs-navigation').on 'show', ->
    $('.course-nav-wrapper').hide()
    $('#step-dots').hide()
    $('.course-nav-slideout').hide()
    $('.course-nav-hamburger').hide()

  $('#cs-navigation').on 'hide', ->
    $('.course-nav-wrapper').show()
    $('#step-dots').show()
    $('.course-nav-slideout').show()
    $('.course-nav-hamburger').show()