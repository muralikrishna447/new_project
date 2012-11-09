$ ->
  $('#log-in form').on 'ajax:error', (xhr, status, error)->
    $(this).find('.error p').remove()
    $(this).find('.input').addClass('error')
    $(this).find('#user_password_input').append('<p>' + status.responseText + '</p>')

  showAuthForm = ->
    id = window.location.hash
    if $(id).hasClass('user-form')
      $('.user-form').hide()
      $(id).show()
      $('#auth-modal').modal('show')

      window.location.hash = ''
      history.pushState('', document.title, window.location.pathname)

  $(window).on 'hashchange', showAuthForm

  showAuthForm()

