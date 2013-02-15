closeEditorWarning = () ->
  "Make sure you press 'Update Recipe' to save any changes."

$ ->
  if $('.update-warning').is('*')
    $('input').keyup ->
      window.onbeforeunload = closeEditorWarning