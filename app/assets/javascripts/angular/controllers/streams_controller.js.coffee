angular.module('ChefStepsApp').controller 'StreamsController', ["$scope", "$resource", "$http", "$filter", ($scope, $resource, $http, $filter) ->

  $scope.init = () ->

    $scope.stream = $resource('/streams/:id')
    $scope.streams = $scope.stream.query(->
      # angular.forEach $scope.streams, (stream, index) ->
      #   $http(
      #     method: 'GET'
      #     url: '/streams/' + stream.id
      #   ).success((data, status, headers, config) ->
      #     # stream.templateUrl = 'activity_stream/' + angular.lowercase(stream.trackable_type) + '/' + stream.action
      #     stream.stream_with_trackable = data
      #   ).error((data, status, headers, config) ->

      #   )
    )

  # $scope.getTrackable = (stream) ->
  #   $http(
  #     method: 'GET'
  #     url: '/streams/' + stream.id
  #   ).success((data, status, headers, config) ->
  #     # stream.templateUrl = 'activity_stream/' + angular.lowercase(stream.trackable_type) + '/' + stream.action
  #     stream.stream_with_trackable = data
  #   ).error((data, status, headers, config) ->

  #   )

  $scope.userImageUrl = (image_id) ->
    if image_id
      image = JSON.parse(image_id)
      image.url + '/convert?fit=crop&w=30&h=30&cache=true'
    else
      'https://www.filepicker.io/api/file/yklhkH0iRV6biUOcXKSw/convert?fit=crop&w=30&h=30&cache=true'

  $scope.mediaObjectImageUrl = (image_id) ->
    if image_id
      image = JSON.parse(image_id)
      image.url + '/convert?fit=crop&w=770&h=433&cache=true'
    else
      ''

  # $scope.addComment = ->
  #   comment = $scope.Comment.save($scope.newComment, ->
  #     $scope.comments.push(comment)
  #     $scope.newComment = {}
  #     $scope.comments_count = $scope.comments.length
  #   )

  # $scope.commentLimit = -6

  # $scope.commentsToggle = ->
  #   if $scope.comments.length > 6
  #     true
  #   else
  #     false

  # $scope.showAllComments = ->
  #   $scope.commentLimit = $scope.comments_count

  # $scope.hideComments = ->
  #   $scope.commentLimit = -6
]