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

$ ->
  $('.assembly_includable_type').change ->
    assembly_inclusion = $(this).closest('.inputs')
    # console.log assembly_inclusion.html()
    # console.log assembly_inclusion.find('.assembly_includable_id').html()
    # assembly_inclusion.find('.assembly_includable_id').append('<option value="foo" selected="selected">Foo</option>')
    includable_id = assembly_inclusion.find('.assembly_includable_id')
    includable_id_selected = includable_id.data('selected')
    includable_id.append(activities_selection_data(includable_id_selected))
  
  $('.inputs').each ->
    assembly_inclusion = $(this)
    includable_id = assembly_inclusion.find('.assembly_includable_id')
    includable_id_selected = includable_id.data('selected')
    includable_id.append(activities_selection_data(includable_id_selected))