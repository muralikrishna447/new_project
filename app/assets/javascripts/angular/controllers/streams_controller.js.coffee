angular.module('ChefStepsApp').controller 'StreamsController', ["$scope", "$resource", "$http", "$filter", ($scope, $resource, $http, $filter) ->

  $scope.init = () ->

    $scope.Stream = $resource('/streams/:id')
    $scope.streams = $scope.Stream.query(->
      angular.forEach $scope.streams, (stream, index) ->
        $http(
          method: 'GET'
          url: '/streams/' + stream.id
        ).success((data, status, headers, config) ->
          stream.templateUrl = 'activity_stream/' + angular.lowercase(stream.trackable_type) + '/' + stream.action
          console.log stream.templateUrl
          stream.stream_with_trackable = data
          console.log stream.stream_with_trackable
        ).error((data, status, headers, config) ->
          console.log 'boo'
        )
    )

  # $scope.userImageUrl = (image_id) ->
  #   if image_id
  #     image = JSON.parse(image_id)
  #     image.url + '/convert?fit=crop&w=30&h=30&cache=true'
  #   else
  #     'https://www.filepicker.io/api/file/yklhkH0iRV6biUOcXKSw/convert?fit=crop&w=30&h=30&cache=true'

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