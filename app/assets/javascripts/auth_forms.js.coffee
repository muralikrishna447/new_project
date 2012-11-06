$ ->
  $('.user-form input').focus ->
    $wrapper = $(this).parent('.input')
    $wrapper.find('p').remove()
    $wrapper.removeClass('error')

  $('#log-in form').on 'ajax:error', (xhr, status, error)->
    $(this).find('.error p').remove()
    $(this).find('.input').addClass('error')
    $(this).find('#user_password_input').append('<p>' + status.responseText + '</p>')

  $('#sign-up form input#terms').on 'change', (event) ->
    setValue =  $(event.currentTarget).is(':checked')
    $("input[value='Sign Up']").attr('disabled', not setValue)

  $('#password-reset form input#user_email').on 'change', (event) ->


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

