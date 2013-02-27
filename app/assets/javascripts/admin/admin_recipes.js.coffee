closeEditorWarning = () ->
  "Make sure you press 'Update Activity' to save any changes."

$ ->
  if $('.update-warning').is('*')
    $(window).keyup ->
      window.onbeforeunload = closeEditorWarning

$ ->
  $('tr').not('.template-row').find('select.unit').select2()

  $(document).on('click', '.admin-button', ( ->
    $('tr').not('.template-row').find('select.unit').select2()
  ));

$ ->
  $('.multi-ingredients').select2(
    {
      closeOnSelect: false,
      placeholder: "Select from recipe ingredients"
    }
  )

$ ->
  $('.multi-ingredients').on 'close', (event) ->

    copy_target = $(this).data('copy-target')
    copy_destination = $(this).data('copy-destination')
    $copy_target = $(copy_target)
    $copy_destination = $(copy_destination)

    $(this).find('option:selected').each ->
      $copy = $copy_target.clone()
      $copy.removeClass('template-row')
      $('input', $copy).val($(this).html())
      $copy.find('.quantity').val($(this).data('quantity'))
      $copy.find('.unit').val($(this).data('unit'))
      $copy_destination.show()
      $copy_destination.append($copy)

    $('tr').not('.template-row').find('select.unit').select2()
    $(this).select2("val", [])
    return true
