$ ->
  $('.modal a').click (e) ->
    e.preventDefault()
    $imgURL = $(this).attr("href")
    img = $(this).closest('.modal').find('.main-image')
    img.fadeOut(200, -> 
      img.attr 'src', $imgURL
    ).fadeIn 400

 $ -> 
  $(window).scroll ->
    if $(window).scrollTop() <= 50
      $('#intro').fadeIn 'fast', 'easeInOutQuad'
      $('.knife').removeClass 'alt'
    else 
      $('#intro').fadeOut 'fast','easeInOutQuad' 
      $('.knife').addClass 'alt'