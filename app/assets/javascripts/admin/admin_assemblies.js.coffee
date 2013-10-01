selection_data = (includable_type, selected) ->
  data = $('#' + includable_type + '_selection_data').data(includable_type + '-selection')
  generate_options(data, selected)

generate_options = (collection, selected) ->
  options = ['<option value></option>']
  $.each collection, (index, value) ->
    if selected == value['id']
      option_markup = "<option value=" + value['id'] + " selected='selected'>" + value['title'] + "</option>"
    else
      option_markup = "<option value=" + value['id'] + ">" + value['title'] + "</option>"
    options.push(option_markup)
  options.join('')

append_options = (fieldset) ->
  includable_type = fieldset.find('select.assembly_includable_type')
  includable_id = fieldset.find('select.assembly_includable_id')
  if includable_type.is('*') && includable_type.val().length
    includable_type_lowercase = includable_type.val().toLowerCase()
    selected = includable_id.data('selected')
    includable_id.html(selection_data(includable_type_lowercase, selected))
  else
    includable_id.html('<option value></option>')

set_position = (fieldset, position) ->
  fieldset.find('.includable_position').val(position)

$ ->
  # $('.assembly_includable_type').on 'change', ->
  #   fieldset = $(this).closest('.inputs')
  #   append_options(fieldset)

  $(document).on 'change', '.assembly_includable_type', ->
    fieldset = $(this).closest('.inputs')
    append_options(fieldset)
  
  $('.inputs').each (index) ->
    fieldset = $(this)
    append_options(fieldset)
    set_position(fieldset, index)

  $("#assembly_inclusions").sortable(
    stop: (event, ui) ->
      $('.inputs').each (index) ->
        fieldset = $(this)
        set_position(fieldset, index)
  )

  $('.assembly_includable_id').each ->
    $(this).select2()

  $('.assembly_includable_type').each ->
    $(this).select2()

  $(document).on 'click', '.add_fields', ->
    $('select.assembly_includable_id').each ->
      $(this).select2()
    $('select.assembly_includable_type').each ->
      $(this).select2()
