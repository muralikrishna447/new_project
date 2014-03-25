# This goes on any child controls whose focus you want to watch
# NB: the same emit comes out of our ui-redactor directive!
@app.directive 'csEmitFocus', ->
  restrict: 'A',

  link: ($scope, $element, $attributes) ->

    $element.on 'focus', ->
      #console.log("Focus:")
      #console.log(this)
      $scope.$emit('childFocused', true)

    $element.on 'blur', ->
      #console.log("Blur:")
      #console.log(this)
      $scope.$emit('childFocused', false)


# This goes on the parent where you want to be aware of child focus
@app.directive 'csWatchFocus', ->
  restrict: 'A',
  scope: true

  link: ($scope, $element, $attributes) ->

    $scope.childFocused = false
    $scope.$on 'childFocused', (event, x) ->
      #console.log "Scope #{$scope.$id} Received focus event #{x} parent element:"
      #console.log $element
      $scope.childFocused = x

