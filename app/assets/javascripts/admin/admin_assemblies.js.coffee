activities_selection_data = (selected) ->
  data = $('#activities_selection_data').data('activities-selection')
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
  includable_id = fieldset.find('.assembly_includable_id')
  includable_id_selected = includable_id.data('selected')
  includable_id.append(activities_selection_data(includable_id_selected))

$ ->
  $('.assembly_includable_type').change ->
    fieldset = $(this).closest('.inputs')
    append_options(fieldset)
  
  $('.inputs').each ->
    fieldset = $(this)
    append_options(fieldset)