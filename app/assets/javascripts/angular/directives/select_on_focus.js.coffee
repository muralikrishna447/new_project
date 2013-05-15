angular.module('ChefStepsApp').directive "csselectonfocus", ->

  # Linker function
  (scope, element, attrs) ->
    element.focus ->
      element.select()

    element.click ->
      element.select()