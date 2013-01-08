$ ->
  $('[data-behavior~=copy-element]').on 'click', (event) ->
    event.preventDefault()
    copy_target = $(this).data('copy-target')
    copy_destination = $(this).data('copy-destination')
    $copy_target = $(copy_target)
    $copy_destination = $(copy_destination)

    $copy = $copy_target.clone()
    $('input', $copy).val('')
    $copy_destination.show()
    $copy_destination.append($copy)

$ ->
  $(document).on 'click', '[data-behavior~=remove-element]', (event) ->
    event.preventDefault()
    removeTarget = $(this).data('remove-target')
    $(this).closest(removeTarget).remove()

$ ->
  $('[data-behavior~=add_activity_to_list]').on 'click', (event) ->
    event.preventDefault()
    src_element = $($(this).data('src-element'))
    dest_list = $($(this).data('dest-list'))
    new_element = $($(this).data('insert-what')).clone()
    new_id = "act_" + src_element.val()
    new_element.attr("id", new_id)
    if ($("body").find('#' + new_id).length > 0)
      alert("That activity is already in the syllabus.")
      return
    name = (src_element.find('option:selected').html())
    new_element.html(new_element.html().replace("Replace", name))
    dest_list.append(new_element)

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

$ ->
  $('ol.allow-nested').nestedSortable(
    maxLevels: 3,
    listType: 'ol',
    handle: 'div',
    items: 'li',
    toleranceElement: '> div'
    placeholder: 'placeholder',
    forcePlaceholderSize:true,
    helper: 'clone',
    opacity: 0.6,
    revert: 250,
    tabSize: 20,
    tolerance: 'pointer',
    isTree: true,
    expandOnHover: 700,
   ).disableSelection()

$ ->
  $('.return_activities').click ->
    arr = $('ol.allow-nested').nestedSortable('toArray')
    result = "["
    for act in arr
      result += "[" + act['item_id'] + ", " + (act['depth'] - 1) + "]" + ", "
    result = result.slice(0, -2)
    result += "]"
    $('#activity_hierarchy').val(result)

$ ->
  $('#activity_select').click ->
    $(this).find("option:last-child").attr({ disabled: 'disabled' })


$ ->
  $('table.nested-records').each (index, el)->
    # show table if more than header and template row are present
    $(el).show() if $(el).find('tr').length > 2
