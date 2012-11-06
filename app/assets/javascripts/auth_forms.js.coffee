$ ->
  $('.user-form input').focus ->
    $wrapper = $(this).parent('.input')
    $wrapper.find('p').remove()
    $wrapper.removeClass('error')

  $('#log-in form').on 'ajax:error', (xhr, status, error)->
    $(this).find('.error p').remove()
    $(this).find('.input').addClass('error')
    $(this).find('#user_password_input').append('<p>' + status.responseText + '</p>')

  showAuthForm = ->
    id = window.location.hash || 'NONE'
    $authForm = $(id + '.user-form')
    $('.user-form').hide()
    if $authForm.length > 0
      $authForm.show()
      $('#auth-modal').modal('show')

  $(window).on 'hashchange', showAuthForm

  showAuthForm()
