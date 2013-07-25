selection_data = (includable_type, selected) ->
  data = $('#' + includable_type + '_selection_data').data('activity-selection')
  generate_options(data, selected)

generate_options = (collection, selected) ->
  options = []
  $.each collection, (index, value) ->
    if selected == value['id']
      option_markup = "<option value=" + value['id'] + " selected='selected'>" + value['title'] + "</option>"
    else
      option_markup = "<option value=" + value['id'] + ">" + value['title'] + "</option>"
    options.push(option_markup)
  options.join('')

append_options = (fieldset) ->
  includable_type = fieldset.find('.assembly_includable_type')
  includable_id = fieldset.find('.assembly_includable_id')
  if includable_type.is('*') && includable_type.val().length
    includable_type_lowercase = includable_type.val().toLowerCase()
    selected = includable_id.data('selected')
    includable_id.append(selection_data(includable_type_lowercase, selected))
  else
    includable_id.html('<option value></option>')

$ ->
  # $('.assembly_includable_type').on 'change', ->
  #   fieldset = $(this).closest('.inputs')
  #   append_options(fieldset)

  $(document).on 'change', '.assembly_includable_type', ->
    fieldset = $(this).closest('.inputs')
    append_options(fieldset)
  
  $('.inputs').each ->
    fieldset = $(this)
    append_options(fieldset)