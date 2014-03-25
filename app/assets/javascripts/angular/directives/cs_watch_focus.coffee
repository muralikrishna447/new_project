# This goes on any child controls whose focus you want to watch
# NB: the same emit comes out of our ui-redactor directive!
@app.directive 'csEmitFocus', ->
  restrict: 'A',

  link: ($scope, $element, $attributes) ->

    $element.on 'focus', ->
      $scope.$emit('childFocused', true)

    $element.on 'blur', ->
      $scope.$emit('childFocused', false)


# This goes on the parent where you want to be aware of child focus
@app.directive 'csWatchFocus', ->
  restrict: 'A',
  scope: true

  link: ($scope, $element, $attributes) ->

    $scope.childFocused = false
    $scope.$on 'childFocused', (event, x) ->
      #console.log "Scope #{$scope.id} Received focus event #{x} on #{$element}"
      $scope.childFocused = x

