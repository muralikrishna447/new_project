# TODO: this is really dorky the way I've hardcoded it, should be generalizable into something
# nice, but I've got macarons to ship today.
angular.module('ChefStepsApp').controller 'TabOrDropdown', ["$scope", ($scope) ->
  $scope.tab = "default"
  $scope.tabTitle = "Overview"
  $scope.showDropdown = false

  $scope.switchTab = (tab, title) ->
    $scope.tab = tab 
    $scope.tabTitle = title
    $scope.showDropdown = false

  $scope.isActiveTab = (tab) ->
    "active" if $scope.tab == tab

]
