$ ->
  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('fieldset').hide()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    parent = $(this).data('parent')
    $('#' + parent).append($(this).data('fields').replace(regexp, time))
    # $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()