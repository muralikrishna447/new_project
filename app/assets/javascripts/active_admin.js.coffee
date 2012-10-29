//= require active_admin/base
//= require twitter/bootstrap/typeahead
//= require jquery-ui-1.9.1.custom

$ ->
  $('[data-behavior~=copy-element]').on 'click', (event) ->
    event.preventDefault()
    copy_target = $(this).data('copy-target')
    copy_destination = $(this).data('copy-destination')
    $copy_target = $(copy_target)
    $copy_destination = $(copy_destination)

    $copy = $copy_target.clone()
    $('input', $copy).val('')
    $copy_destination.append($copy)

$ ->
  $('[data-behavior~=remove-element]').on 'click', (event) ->
    event.preventDefault()
    removeTarget = $(this).data('remove-target')
    $(this).closest(removeTarget).remove()

