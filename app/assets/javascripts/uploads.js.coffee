window.uploadPhotoPreview = (preview, file) ->
  if file
    width = 300
    url = JSON.parse(file).url
    preview.attr('src', [url , "/convert?fit=max&w=", width, "&h=", Math.floor(width * 16.0 / 9.0)].join(""))
    preview.show()
  else
    preview.parent().hide()
    preview.attr('src', '')

window.changeButton = (button) ->
  button.text('Change Photo')
  button.css 'font-size', '14px'
  button.css 'top', '10px'
  button.css 'left', 'inherit'
  button.css 'right', '10px'
  button.css 'margin-left', '0px'

$ ->
  $(document).on 'click', '.upload-photo-btn', (event) ->
    button = $(this)
    event.preventDefault()
    wrapper = $(this).closest('.upload-wrapper')
    filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3", path: '/users_uploads/'}, (fpfiles) =>
      file = wrapper.find('.upload-photo-field')
      file.val(JSON.stringify(fpfiles[0]))
      preview = wrapper.find('.upload-photo-preview')
      uploadPhotoPreview(preview, file.val())
      changeButton(button)