angular.module('ChefStepsApp').controller 'CommentsController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->

  Comment = $resource(window.location.pathname + '/comments/:id')
  $scope.comments = Comment.query() 

  $scope.userImageUrl = (image_id) ->
    image = JSON.parse(image_id)
    image.url + '/convert?fit=crop&w=30&h=30&cache=true'

  $scope.addComment = ->
    comment = Comment.save($scope.newComment, ->
      $scope.comments.push(comment)
      $scope.newComment = {}
    )
]