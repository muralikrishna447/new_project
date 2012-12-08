$ ->
  $('[data-behavior~=container-height]').each ->
    p = $(this).parent()
    height = p.height() - ($(this).offset().top - p.offset().top)
    $(this).height(height)
