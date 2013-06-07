angular.module('ChefStepsApp').directive "csselectonfocus", ->
  scope: true
  link: (scope, element, attrs) ->

    scope.preventNextMouseUp = false

    element.focus ->
      element.select()
      scope.preventNextMouseUp = true

    # http://stackoverflow.com/questions/1269722/selecting-text-on-focus-using-jquery-not-working-in-safari-and-chrome
    # but I had to add the extra bit about only preventing on the next mouseup after focus, otherwise another click in
    # the text to unselect all and move the cursor wouldn't work
    element.mouseup (event) ->
      console.log scope.preventNextMouseUp
      event.preventDefault() if scope.preventNextMouseUp
      scope.preventNextMouseUp = false
      true