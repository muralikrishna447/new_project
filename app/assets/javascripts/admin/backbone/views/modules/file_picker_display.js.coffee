ChefStepsAdmin.Views.Modules.FilePickerDisplay =
  imageOptions: {}

  convertImage: (url) ->
    optionsQueryString = $.param(@imageOptions)
    "#{url}/convert?#{optionsQueryString}"

