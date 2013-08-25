# $ ->
#   $('.modal a').click (e) ->
#     e.preventDefault()
#     $imgURL = $(this).attr("href")
#     img = $(this).closest('.modal').find('.main-image')
#     img.fadeOut(100, -> 
#       img.attr 'src', $imgURL
#     ).fadeIn 100

$ -> 
  $(window).scroll ->
    if $(window).scrollTop() <= 50
      $('#intro').fadeIn 'fast', 'easeInOutQuad'
      $('.knife').removeClass 'alt'
    else 
      $('#intro').fadeOut 'fast','easeInOutQuad' 
      $('.knife').addClass 'alt'

$ -> 
  $('.modal a').click (e) ->
    e.preventDefault()
    $(this).closest('.modal-body').children('img').hide()
    idx = $(this).parent().index()
    $($(this).closest('.modal-body').children('img')[idx]).removeClass('hidden').fadeIn()
