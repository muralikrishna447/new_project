@app.controller 'KitController', ['$scope', '$http', '$routeParams', ($scope, $http, $routeParams) ->
  console.log $routeParams
  $scope.kit = {}
  $scope.currentItem = {}
  $scope.currentItemActivities = []
  $scope.introClass = 'intro-active'
  $scope.navClass = ''
  $scope.viewerClass = ''

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
    $scope.introClass = ''
    $scope.navClass = ''
    $scope.viewerClass = 'viewer-active'

  $scope.toggleIntro = ->
    if $scope.introClass == 'intro-active'
      $scope.introClass = ''
    else
      $scope.introClass = 'intro-active'

  $scope.toggleNav = ->
    if $scope.navClass == 'nav-active'
      $scope.navClass = ''
    else
      $scope.navClass = 'nav-active'

  $scope.toggleViewer = ->
    if $scope.viewerClass == 'viewer-active'
      $scope.viewerClass = ''
    else
      $scope.viewerClass = 'viewer-active'
]