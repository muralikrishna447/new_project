angular.module('ChefStepsApp').filter "cleanContenteditable", ->
  (text) ->
    if text
      text = text.replace(/<div>/g, '')
      text = text.replace(/<\/div>/g, '<br>')
      text = text.replace(/<p>/g, '')
      text = text.replace(/<\/p>/g, '<br>')
      text = text.replace(/(<br>)+/g, '<br>')
    text
