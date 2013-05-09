# This guy is responsible for showing a highlight on hover that indicates it can
# be edited, and switching between the show and edit children when activated. It
# delegates to the cseditgroup to manage the radio-like behavior so that only one
# pair is activated at a time, and to the app for the undo/redo.
angular.module('ChefStepsApp').directive 'cseditpair', ->
  restrict: 'E',
  transclude: true,
  replace: true,
  scope: true,

  controller: ['$rootScope', '$scope', '$element', ($rootScope, $scope, $element) ->
    $scope.offerEdit = ->
      # Radio behavior
      $rootScope.$broadcast('stop_offering_edits')
      if $scope.editMode && ! $scope.active
        $scope.editOffered = true

    $scope.$on 'stop_offering_edits', ->
      $scope.unofferEdit()

    $scope.unofferEdit = ->
      $scope.editOffered = false

    # Edit one group
    $scope.startEdit = ->
      $scope.unofferEdit()
      # Radio behavior
      $rootScope.$broadcast('stop_edits')
      $scope.active = true
      event.stopPropagation()

    $scope.$on 'stop_edits', ->
      if $scope.active
        $scope.active = false
        $scope.$emit('maybe_save_undo')
  ]

  template: '<div class="edit-pair" ng-switch="" on="active" ng-mouseover="offerEdit()">' +
              '<div class="edit-target" ng-mouseout="unofferEdit()" ng-click="startEdit()" ng-show="editOffered">' +
                '<div class="remove-target" ng-show="removeAllowed()" ng-click="removeItem()">' +
              '</div>' +
              '<div ng-transclude></div>' +
            '</div>'

angular.module('ChefStepsApp').directive 'cseditpairedit', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-when="true" ng-transclude></div>'

angular.module('ChefStepsApp').directive 'cseditpairshow', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-default="" ng-transclude></div>'