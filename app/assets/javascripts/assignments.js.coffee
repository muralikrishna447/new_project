$ ->
  $('.assignment').click ->
    box = $(this).find('.media-box-2')
    activity_id = box.data('object').split('-')[1]
    activity_title = $.trim(box.text())

    $('#upload_activity_id').val(activity_id)
    $('#upload_title').val(activity_title)