@app.controller 'KitController', ['$scope', '$http', '$routeParams', ($scope, $http, $routeParams) ->
  console.log $routeParams
  $scope.kit = {}
  $scope.currentItem = {}
  $scope.currentItemActivities = []
  $scope.state = 'intro-active'

  $scope.loadKit = (id)->
    $http.get('/kits/' + id + '/show_as_json').then (response) ->
      $scope.kit = response.data

  $scope.loadItem = (item) ->
    switch item.includable_type
      when 'Activity'
        $http.get('/activities/' + item.includable_id + '/as_json').then (response) ->
          $scope.currentItem = response.data
    # $scope.currentItemActivities = []
    # $scope.currentItem = item
    # angular.forEach $scope.currentItem.includable.assembly_inclusions, (inclusion) ->
    #   $http.get('/activities/' + inclusion.includable_id + '/as_json').then (response) ->
    #     $scope.currentItemActivities.push(response.data)
    $scope.changeStateTo('page-active')

  $scope.changeStateTo = (state) ->
    if $scope.state != state
      $scope.state = state
]