angular.module('ChefStepsApp').filter "newlines", ->
  (text) ->
    text.replace(/\n/g, '<br/>')