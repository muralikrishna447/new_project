@app.controller 'KitController', ['$scope', '$http', ($scope, $http) ->
  $scope.kit = {}
  $scope.currentItem = {}
  $scope.currentItemActivities = []
  $scope.state = 'intro-active'

  $scope.loadKit = ->
    $http.get('/kits/pastrami-box/show_as_json').then (response) ->
      $scope.kit = response.data

  $scope.loadItem = (item) ->
    $scope.currentItemActivities = []
    $scope.currentItem = item
    angular.forEach $scope.currentItem.includable.assembly_inclusions, (inclusion) ->
      $http.get('/activities/' + inclusion.includable_id + '/as_json').then (response) ->
        $scope.currentItemActivities.push(response.data)
    $scope.changeStateTo('page-active')

  $scope.changeStateTo = (state) ->
    if $scope.state != state
      $scope.state = state
]