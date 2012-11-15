$ ->
  showAuthModal = ->
    id = window.location.hash
    return if id == '#_=_'
    if $(id).hasClass('user-form')
      $('.user-form').hide()
      $(id).show()
      $('#auth-modal').modal('show')

      window.location.hash = ''
      history.pushState('', document.title, window.location.pathname)

  $(window).on 'hashchange', showAuthModal

  showAuthModal()

