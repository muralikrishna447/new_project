closeEditorWarning = () ->
  'Make sure the recipe has been updated before editing the associated ingredients'

# window.onkeyup ->
#   alert 'hello'
$ ->
  if $('.update-warning').is('*')
    # alert 'hello'
    window.onbeforeunload = closeEditorWarning
# window.onbeforeunload = closeEditorWarning

# $ ->
#   $('.upload-warning').click ->
#     closeEditorWarning()