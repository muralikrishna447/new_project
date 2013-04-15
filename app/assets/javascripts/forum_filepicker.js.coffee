$ ->
  $(document).on "click", ".cleditorButton", (event) ->
    if $(this).attr('title') == 'Insert Image'
      event.preventDefault()
      doc = $('.cleditorMain').find('iframe')[0].contentWindow.document

      filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3"}, (fpfiles) =>
        console.log(JSON.stringify(fpfiles))
        url = JSON.stringify(fpfiles[0]['url'])
        convert = "/convert?fit=max&w=400"
        url_with_conversion = JSON.parse(url) + convert
        content = "<img src='" + url_with_conversion + "'/>"
        $(doc).find('body').append(content)