$ ->
  $('.user-form input').focus ->
    $wrapper = $(this).parent('.input')
    $wrapper.find('p').remove()
    $wrapper.removeClass('error')

  $('#log-in form').on 'ajax:error', (xhr, status, error)->
    $(this).find('.error p').remove()
    $(this).find('.input').addClass('error');
    $(this).find('#user_password_input').append('<p>' + status.responseText + '</p>')

  $formsCarousel = $('#auth-modal .carousel')
  $formsCarousel.carousel(interval: false)

  $('.auth-trigger').on 'click', ->
    $formsCarousel.carousel($(this).data('form-number'))
    $($(this).data('target')).modal('show')

