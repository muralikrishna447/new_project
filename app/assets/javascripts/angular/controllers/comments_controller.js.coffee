angular.module('ChefStepsApp').controller 'CommentsController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->
  # Poll = $resource('/polls/:id/show_as_json', {id:  $('#poll').data("poll-id")})
  # $scope.poll = Poll.get()

  # Comments = $resource('/comments?commentable_type=:type&commentable_id=:id')
  # alert window.location.pathname
  Comment = $resource(window.location.pathname + '/comments/:id')
  $scope.comments = Comment.query()

  $scope.userImageUrl = (image_id) ->
    image = JSON.parse(image_id)
    console.log image
    image.url + '/convert?fit=crop&w=30&h=30&cache=true'

  $scope.addComment = ->
    comment = Comment.save($scope.newComment)
    $scope.comments.push(comment)
    $scope.newComment = {}
]