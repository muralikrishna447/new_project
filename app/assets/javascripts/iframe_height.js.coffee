window.adjust_iframe_height = (iframe) ->
  iframe.height = iframe.contentWindow.document.body.scrollHeight + "px"