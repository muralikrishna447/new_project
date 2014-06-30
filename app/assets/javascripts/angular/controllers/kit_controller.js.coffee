@app.controller 'KitController', ['$scope', '$http', '$routeParams', ($scope, $http, $routeParams) ->
  console.log $routeParams
  $scope.kit = {}
  $scope.currentItem = {}
  $scope.currentItemActivities = []
  $scope.introClass = 'intro-active'
  $scope.navClass = ''
  $scope.viewerClass = ''
  $scope.introActive = true
  $scope.navActive = false
  $scope.viewerActive = false

  $scope.loadKit = (id)->
    $http.get('/kits/' + id + '/show_as_json').then (response) ->
      $scope.kit = response.data

  $scope.loadItem = (item) ->
    $scope.currentInclusion = item
    switch item.includable_type
      when 'Activity'
        $http.get('/activities/' + item.includable_id + '/as_json').then (response) ->
          $scope.currentItem = response.data
      when 'Assembly'
        $scope.currentItemActivities = []
        $scope.currentItem = item
        angular.forEach $scope.currentItem.includable.assembly_inclusions, (inclusion) ->
          $http.get('/activities/' + inclusion.includable_id + '/as_json').then (response) ->
            $scope.currentItemActivities.push(response.data)
    $scope.introActive = false
    $scope.navActive = false
    $scope.viewerActive = true

  $scope.toggleIntro = ->
    if !$scope.introActive
      $scope.introActive = ! $scope.introActive

  $scope.toggleNav = ->
    $scope.navActive = ! $scope.navActive

  $scope.toggleViewer = ->
    $scope.viewerActive = ! $scope.viewerActive
]