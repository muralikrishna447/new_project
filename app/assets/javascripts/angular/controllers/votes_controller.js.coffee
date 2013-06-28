# angular.module('ChefStepsApp').controller 'VotesController', ["$scope", "$resource", "$location", "$http", ($scope, $resource, $location, $http) ->
  
#   # $scope.voteObject = (votable_type, votable_id) ->
#   #   url = '/votes?votable_type=' + votable_type + '&votable_id=' + votable_id
#   #   $http(
#   #     method: 'POST'
#   #     url: url
#   #   ).success((data, status, headers, config) ->
#   #     $scope.current_user_votes = true
#   #     $scope.votes_count += 1
#   #     # TODO will eventually need to angularize the alert notification system
#   #     $('.alert-container').append("<div class='alert alert-success'><button class='close' data-dismiss='alert' type='button'>x</button><h4 class='alert-message'>You voted for this!</h4><div class='lblock'></div></div>")
#   #   ).error((data, status, headers, config) ->
#   #     $('.alert-container').append("<div class='alert alert-error'><button class='close' data-dismiss='alert' type='button'>x</button><h4 class='alert-message'><a href='/sign_up'>Create an account</a> or <a href='/sign_in'>sign in</a> to vote this.</h4><div class='lblock'></div></div>")
#   #   )
# ]

angular.module('ChefStepsApp').controller 'VotesController', ["$scope", "$resource", ($scope, $resource) ->
  Poll = $resource('/polls/:id/show_as_json', {id:  $('#poll').data("poll-id")})
  $scope.poll = Poll.get()
  console.log $scope.poll
]