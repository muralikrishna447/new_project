uploadPhotoPreview = (preview, file) ->
  if file
    admin_width = 200
    if file[0] == '{'
      url = JSON.parse(file).url
      preview.attr('src', [url , "/convert?fit=max&w=", admin_width, "&h=", Math.floor(admin_width * 16.0 / 9.0)].join(""))
    else
      # Legacy, this can go as soon as rake task is run
      url = "http://d2eud0b65jr0pw.cloudfront.net/" + file
      preview.attr('src', url)
    preview.parent().show()
  else
    preview.parent().hide()
    preview.attr('src', '')

$ ->
  $(document).on 'click', '.upload-photo-btn', (event) ->
    event.preventDefault()
    wrapper = $(this).closest('.upload-wrapper')
    filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3"}, (fpfiles) =>
      file = wrapper.find('.upload-photo-field')
      file.val(JSON.stringify(fpfiles[0]))
      preview = wrapper.find('.upload-photo-preview')
      uploadPhotoPreview(preview, file.val())