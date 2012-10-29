//= require active_admin/base
//= require twitter/bootstrap/typeahead

$ ->
  $copy_button = $('[data-behavior~=copy-element]')
  copy_target = $copy_button.data('copy-target')
  copy_destination = $copy_button.data('copy-destination')

  $copy_target = $(copy_target)
  $copy_destination = $(copy_destination)

  $copy_button.on 'click', (event) ->
    event.preventDefault()
    $copy = $copy_target.clone()
    $('input', $copy).val('')
    $copy_destination.append($copy)

$ ->
  $('[data-behavior~=remove-element]').on 'click', (event) ->
    event.preventDefault()
    removeTarget = $(this).data('remove-target')
    $(this).closest(removeTarget).remove()

