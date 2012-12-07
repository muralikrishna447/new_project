ChefStepsAdmin.Views.Modules.FilePickerDisplay =
  imageOptions: {}

  convertImage: (url) ->
    return url unless url
    optionsQueryString = $.param(@imageOptions)
    "#{url}/convert?#{optionsQueryString}"

