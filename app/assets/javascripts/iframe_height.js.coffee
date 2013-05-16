window.adjust_iframe_height = (iframe_id) ->
  iframe = document.getElementById(iframe_id)
  if iframe
    iframe.height = ''
    iframe.height = iframe.contentWindow.document.body.scrollHeight + "px"