angular.module('ChefStepsApp').filter "nbsp", ->
  (text) ->
    text.replace(/\s/g, '&nbsp;') 