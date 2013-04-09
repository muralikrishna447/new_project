$ ->
  $('[data-behavior~=copy-element]').on 'click', (event) ->
    event.preventDefault()
    copy_target = $(this).data('copy-target')
    copy_destination = $(this).data('copy-destination')
    $copy_target = $(copy_target)
    $copy_destination = $(copy_destination)

    $copy = $copy_target.clone()
    $copy.removeClass('template-row')
    $('input', $copy).val('')
    $copy_destination.show()
    $copy_destination.append($copy)

    callback = $(this).data('callback')
    if callback != ""
      window[callback]($copy)


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

    # Existing activity
    if src_element.get(0).tagName == 'SELECT'
      new_id = "act_" + src_element.val()
      name = (src_element.find('option:selected').html())

    # New activity
    else
      name = src_element.val()
      new_id = "act_" + (100000 + (Date.now() % 100000)).toString()

    if ($("body").find('#' + new_id).length > 0)
      alert("That activity is already in the syllabus.")
      return

    new_element.attr("id", new_id)
    new_element.html(new_element.html().replace("Replace", name))
    new_element.data("name", name)
    dest_list.append(new_element)
    new_element.parents(".mjs-nestedSortable-leaf").removeClass("mjs-nestedSortable-leaf").addClass("mjs-nestedSortable-branch").addClass("mjs-nestedSortable-expanded")

$ ->
  fixHelper = (e, ui) ->
    ui.children().each ->
      $(this).width($(this).width())
    ui

  $('table.sortable').sortable(
    cursor: 'move',
    helper: fixHelper,
    items: 'tr:not(:first)',
    containment: 'parent',
    axis: 'y'
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
  $(document).on "click", ".disclose", ->
    $(this).closest('li').toggleClass('mjs-nestedSortable-collapsed', '300').toggleClass('mjs-nestedSortable-expanded', '300')

$ ->
  $('.return_activities').click ->
    arr = $('ol.allow-nested').nestedSortable('toArray')
    result = "["
    for act in arr
      li = $('ol.allow-nested').find("#act_" + act['item_id'])
      title = $.trim(li.data("name"))
      result += "[" + act['item_id'] + ", " + (act['depth'] - 1) + ', "' + title + '"]' + ", "
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


filepickerPreviewUpdateOne = (preview, fpfile) ->
  if fpfile
    admin_width = 200
    if fpfile[0] == '{'
      url = JSON.parse(fpfile).url
      preview.attr('src', [url , "/convert?fit=max&w=", admin_width, "&h=", Math.floor(admin_width * 16.0 / 9.0)].join(""))
    else
      # Legacy, this can go as soon as rake task is run
      url = "http://d2eud0b65jr0pw.cloudfront.net/" + fpfile
      preview.attr('src', url)
    preview.parent().show()
  else
    preview.parent().hide()
    preview.attr('src', '')


filepickerPreviewUpdateAll = ->
  $('.filepicker-real-file').each ->
    preview = $(this).parent().find('.filepicker-preview')
    val = $(this).attr('value')
    filepickerPreviewUpdateOne(preview, val)

$ ->
  filepickerPreviewUpdateAll()

$ ->
  $(document).on "click", ".filepicker-pick-button", (event) ->
    event.preventDefault()
    filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3"}, (fpfiles) =>
      $(_this).parents('.filepicker-group').find('.filepicker-real-file').val(JSON.stringify(fpfiles[0]))
      filepickerPreviewUpdateAll()

  $(document).on "click", ".remove-filepicker-image", (event) ->
    $(this).parents('.filepicker-group').find('.filepicker-real-file').val('')
    filepickerPreviewUpdateAll()

setupFilepickerDropPanes = ->
  $('.filepicker-drop-pane').each ->
    filepicker.makeDropPane $(this),
      dragEnter: =>
        $(this).html("Drop to upload").css("border-style", "inset")
      dragLeave: =>
        $(this).html("Or drop file here").css("border-style", "outset")
      onSuccess: (fpfiles) =>
        $(_this).parents('.filepicker-group').find('.filepicker-real-file').val(JSON.stringify(fpfiles[0]))
        filepickerPreviewUpdateAll()
        $(this).html("Or drop file here").css("border-style", "outset")
      onProgress: (percentage) =>
        $(this).text("Uploading ("+percentage+"%)")

$ ->
  setupFilepickerDropPanes()
  $(document).on "click", (event) ->
    setupFilepickerDropPanes()

restoreVersion = (version) ->
  path = $('#urls').data('restore_version_admin_activity_path') + "?version=" + version
  window.location = path

updateDiff =  ->
  version_left = $('#select-left').val()
  version_right = $('#select-right').val()
  path = $('#urls').data('get_diff_admin_activity_path') + "?version_left=" + version_left + "&version_right=" + version_right
  $('#loading-diff').fadeIn()
  $.ajax path,
    success: (data, status, xhr) ->
      $('#preview-diff').html(data)
      $('#loading-diff').fadeOut()


$ ->
  updateDiff()

  $('.preview-group select').on "change", (event) ->
    activity_path = $('#urls').data('activity_path') + "?version=" + $(this).val()
    $(this).closest('.preview-group').find('.preview').attr("src", activity_path)
    $(this).closest('.preview-group').find('.loading-indicator').fadeIn()
    updateDiff()

  $('#make-live-left').click ->
    restoreVersion($('#select-left').val())

  $('#make-live-right').click ->
    restoreVersion($('#select-right').val())

  $('#preview-left').load ->
    $('#loading-left').fadeOut()

  $('#preview-right').load ->
    $('#loading-right').fadeOut()






