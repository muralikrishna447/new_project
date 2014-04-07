angular.module('ChefStepsApp').controller 'MadlibController', ["$rootScope", "$scope", ($rootScope, $scope) ->

  $scope.getTotalUsers = ->
    $scope.totalUsers || 36297

  # For Kiosk
  $scope.madlibPage = ''
  $scope.showPage1 = true
  $scope.showPage2 = false

  $scope.nextPage = ->
    $scope.madlibPage = 'madlib-page-2'
    $scope.showPage1 = false
    $scope.showPage2 = true

  $scope.prevPage = ->
    $scope.madlibPage = ''
    $scope.showPage1 = true
    $scope.showPage2 = false
]