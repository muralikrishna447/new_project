angular.module('ChefStepsApp').filter "trim", ->
  (text) ->
    $.trim(text)
