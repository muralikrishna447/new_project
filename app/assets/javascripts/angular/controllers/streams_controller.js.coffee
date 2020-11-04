angular.module('ChefStepsApp').controller 'StreamsController', ["$scope", "$resource", "$http", "$filter", ($scope, $resource, $http, $filter) ->

  $scope.init = () ->

    $scope.page = 1
    $scope.stream = $resource('/streams/:id')
    $scope.streams = $scope.stream.query(->
      $scope.hideSpinner = true
      $scope.showMoreButton = true
    )

  $scope.userImageUrl = (image_id) ->
    if image_id
      image = JSON.parse(image_id)
      image.url.replace("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net") + '/convert?fit=max&w=30&h=30&cache=true'
    else
      'https://d3awvtnmmsvyot.cloudfront.net/api/file/yklhkH0iRV6biUOcXKSw/convert?fit=max&w=30&h=30&cache=true'

  $scope.mediaObjectImageUrl = (image_id) ->
    if image_id
      image = JSON.parse(image_id)
      image.url.replace("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net") + '/convert?fit=max&w=770&h=433&cache=true'
    else
      ''

  $scope.loadMore = () ->
    $scope.page+=1
    $http(
      method: 'GET'
      url: '/streams?page=' + $scope.page
    ).success((data, status, headers, config) ->
      angular.forEach data, (data_item, index) ->
        $scope.streams.push(data_item)
    ).error((data, status, headers, config) ->

    )

  $scope.streamViewTemplate = (stream) ->
    'stream_views/' + stream.event_type + '.html'

]

window.track_viewed_profile_through_stream = ->
  console.log('Viewed User Profile through Stream');

window.track_viewed_item_through_stream = ->
  console.log('Viewed Item through Stream');

window.track_viewed_course_through_signed_in_homepage = ->
  console.log('Viewed Course Through Signed In Homepage');
