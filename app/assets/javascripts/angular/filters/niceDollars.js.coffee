angular.module('ChefStepsApp').filter "niceDollars", ->
  (input) ->
    "$" + parseFloat(input).toFixed(2).replace('.00', '')
