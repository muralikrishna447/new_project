angular.module('ChefStepsApp').controller 'CommentsController', ["$scope", "$resource", "$http", "$filter", ($scope, $resource, $http, $filter) ->

  Comment = $resource(window.location.pathname + '/comments/:id')
  $scope.comments = Comment.query(->
    $scope.comments_count = $scope.comments.length
  ) 

  $scope.userImageUrl = (image_id) ->
    image = JSON.parse(image_id)
    image.url + '/convert?fit=crop&w=30&h=30&cache=true'

  $scope.addComment = ->
    comment = Comment.save($scope.newComment, ->
      $scope.comments.push(comment)
      $scope.newComment = {}
    )

  $scope.commentLimit = -6

  $scope.showAllComments = ->
    $scope.commentLimit = $scope.comments_count

  $scope.hideComments = ->
    $scope.commentLimit = -6
]