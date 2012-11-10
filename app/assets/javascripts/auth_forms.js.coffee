$ ->
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

