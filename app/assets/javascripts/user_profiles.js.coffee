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