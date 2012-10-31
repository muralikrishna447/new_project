//= require active_admin/base
//= require twitter/bootstrap/typeahead

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
  $(document).on 'click', '[data-behavior~=remove-element]', (event) ->
    event.preventDefault()
    removeTarget = $(this).data('remove-target')
    $(this).closest(removeTarget).remove()

$ ->
  fixHelper = (e, ui) ->
    ui.children().each ->
      $(this).width($(this).width())
    ui

  $('table.sortable').sortable(
    cursor: 'move',
    helper: fixHelper,
    items: 'tr:not(:first)',
    containment: 'parent'
  ).disableSelection()
