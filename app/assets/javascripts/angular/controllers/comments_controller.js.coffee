angular.module('ChefStepsApp').controller 'CommentsController', ["$scope", "$resource", "$http", "$filter", ($scope, $resource, $http, $filter) ->

  $scope.init = (commentable_type, commentable_id) ->
    $scope.commentable_type = commentable_type
    $scope.commentable_id = commentable_id
    Comment = $resource('/' + $scope.commentable_type + '/' + $scope.commentable_id + '/comments')
    $scope.comments = Comment.query(->
      $scope.comments_count = $scope.comments.length
    ) 

  $scope.userImageUrl = (image_id) ->
    if image_id
      image = JSON.parse(image_id)
      image.url + '/convert?fit=crop&w=30&h=30&cache=true'
    else
      'http://www.placehold.it/30x30/cccccc/cccccc&text=ChefSteps'

  $scope.addComment = ->
    comment = Comment.save($scope.newComment, ->
      $scope.comments.push(comment)
      $scope.newComment = {}
      $scope.comments_count = $scope.comments.length
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