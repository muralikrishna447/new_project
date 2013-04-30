$ ->
  $('.assignment').click ->
    activity_id = $(this).find('.media-box-2').data('object').split('-')[1]
    $('#upload_activity_id').val(activity_id)