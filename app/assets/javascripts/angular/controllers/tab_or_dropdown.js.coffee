# TODO: this is really dorky the way I've hardcoded it, should be generalizable into something
# nice, but I've got macarons to ship today.
angular.module('ChefStepsApp').controller 'TabOrDropdown', ["$scope", '$route', '$routeParams', ($scope, $route, $routeParams) ->
  $scope.tab = "default"
  $scope.tabTitle = "Overview"
  $scope.showDropdown = false

  $scope.switchTab = (tab, title) ->
    tab = "default" if (tab == "overview") || (! tab)
    title = tab.charAt(0).toUpperCase() + tab.slice(1) if ! title
    $scope.tab = tab 
    $scope.tabTitle = title
    $scope.showDropdown = false

  $scope.isActiveTab = (tab) ->
    "active" if $scope.tab == tab

  $scope.routeParams = $routeParams
  $scope.route = $route

  $scope.$on "$routeChangeSuccess", ($currentRoute, $previousRoute) ->
    $scope.switchTab($scope.routeParams.slug)
]
