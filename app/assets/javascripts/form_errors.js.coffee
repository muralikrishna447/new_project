$ ->
  $('.user-form input').focus ->
    $wrapper = $(this).parent('.input')
    $wrapper.find('p').remove()
    $wrapper.removeClass('error')

