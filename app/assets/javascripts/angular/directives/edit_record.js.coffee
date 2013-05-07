angular.module('ChefStepsApp').directive 'cseditrecord', ->
  scope: true,
  controller: ['$scope', '$element', ($scope, $element) ->

    $scope.pairs = []

    $scope.deactivateAll = ->
      any_active = false
      angular.forEach $scope.pairs, (pair) ->
        if pair.active
          pair.active = false
          any_active = true
      if any_active
        $scope.addUndo()
        window.wysiwygDeactivatedCallback($element)

    $scope.unofferAll = ->
      angular.forEach $scope.pairs, (pair) ->
        pair.editOffered = false

    $scope.$on 'end_all_edits', ->
      $scope.deactivateAll()

    $scope.activate = (pair) ->
      $scope.deactivateAll()
      pair.active = true

    $scope.addPair = (pair) ->
      pair.active = false
      $scope.pairs.push(pair)
  ]