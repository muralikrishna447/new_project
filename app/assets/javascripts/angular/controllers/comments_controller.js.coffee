angular.module('ChefStepsApp').controller 'CommentsController', ["$scope", "$resource", "$http", "$filter", ($scope, $resource, $http, $filter) ->

  $scope.init = (commentable_type, commentable_id) ->
    $scope.commentable_type = commentable_type
    $scope.commentable_id = commentable_id

    $scope.Comment = $resource('/' + $scope.commentable_type + '/' + $scope.commentable_id + '/comments')
    $scope.comments = $scope.Comment.query(->
      $scope.comments_count = $scope.comments.length
    ) 

  $scope.userImageUrl = (image_id) ->
    if image_id
      image = JSON.parse(image_id)
      window.cdnURL(image.url + '/convert?fit=crop&w=30&h=30&cache=true')
    else
      window.cdnURL('https://www.filepicker.io/api/file/yklhkH0iRV6biUOcXKSw/convert?fit=crop&w=30&h=30&cache=true')

  $scope.addComment = ->
    comment = $scope.Comment.save($scope.newComment, ->
      $scope.comments.push(comment)
      $scope.newComment = {}
      $scope.comments_count = $scope.comments.length
      mixpanel.track('Commented', {'Commentable': $scope.commentable_type + "_" + $scope.commentable_id })

    )

  $scope.commentLimit = -6

  $scope.commentsToggle = ->
    if $scope.comments.length > 6
      true
    else
      false

  $scope.showAllComments = ->
    $scope.commentLimit = $scope.comments_count

  $scope.hideComments = ->
    $scope.commentLimit = -6
]