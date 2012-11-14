$ ->
  $('[data-click-toggle]').on 'click', (event) ->
    $(this).toggleClass($(this).data('click-toggle'))

