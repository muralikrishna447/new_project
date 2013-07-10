angular.module('ChefStepsApp').controller 'CommentsController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->
  # Poll = $resource('/polls/:id/show_as_json', {id:  $('#poll').data("poll-id")})
  # $scope.poll = Poll.get()

  # Comments = $resource('/comments?commentable_type=:type&commentable_id=:id')
  Comments = $resource(document.URL + '/comments')
  $scope.comments = Comments.get()
]