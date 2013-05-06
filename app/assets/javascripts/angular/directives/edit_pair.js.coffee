# This guy is responsible for showing a highlight on hover that indicates it can
# be edited, and switching between the show and edit children when activated. It
# delegates to the cseditgroup to manage the radio-like behavior so that only one
# pair is activated at a time, and to the app for the undo/redo.
angular.module('ChefStepsApp').directive 'cseditpair', ->
  restrict: 'E',
  require: '^cseditgroup',
  transclude: true,
  replace: true,
  scope: true,

  link: (scope, element, attrs, groupControl) ->
    scope.addPair(scope)

  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.offerEdit = ->
      if $scope.editMode && ! $scope.active
        $($element).find('.edit-target').show()

    $scope.unofferEdit = ->
      $($element).find('.edit-target').hide()

    # Edit one group
    $scope.startEdit = ->
      $scope.unofferEdit()
      $scope.activate($scope)
      event.stopPropagation()
  ]

  template: '<div class="edit-pair" ng-switch="" on="active" ng-mouseover="offerEdit()"><div class="edit-target hide" ng-mouseout="unofferEdit()" ng-click="startEdit()"></div><div ng-transclude></div></div>'

angular.module('ChefStepsApp').directive 'cseditpairedit', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-when="true" ng-transclude></div>'

angular.module('ChefStepsApp').directive 'cseditpairshow', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-when="false" ng-transclude></div>'