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

angular.module('ChefStepsApp').controller 'VotesController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->
  Poll = $resource('/polls/:id/show_as_json', {id:  $('#poll').data("poll-id")})
  $scope.poll = Poll.get()

  # $scope.voteObject = (votable) ->
  #   # console.log 'VOTABLE:'
  #   # console.log votable.id
  #   url = '/votes?votable_type=' + 'PollItem' + '&votable_id=' + votable.id
  #   $http(
  #     method: 'POST'
  #     url: url
  #   ).success((data, status, headers, config) ->
  #     # $scope.current_user_votes = true
  #     # $scope.votes_count += 1
  #     votable.votes_count +=1
  #     votable.title = 'VOTED'
  #     console.log votable
  #     console.log votable.votes_count
  #     $scope.current_user_voted_for_this(votable)
  #     # TODO will eventually need to angularize the alert notification system
  #     $('.alert-container').append("<div class='alert alert-success'><button class='close' data-dismiss='alert' type='button'>x</button><h4 class='alert-message'>You voted for this!</h4><div class='lblock'></div></div>")
  #   ).error((data, status, headers, config) ->
  #     $('.alert-container').append("<div class='alert alert-error'><button class='close' data-dismiss='alert' type='button'>x</button><h4 class='alert-message'><a href='/sign_up'>Create an account</a> or <a href='/sign_in'>sign in</a> to vote this.</h4><div class='lblock'></div></div>")
  #   )

  $scope.voteObject = (votable) ->
    console.log $scope
    # console.log $scope.poll['poll_items']

  $scope.current_user_voted_for_this = (votable) ->
    # console.log $scope.current_user_votes
    # console.log "Votable ID:" + votable.id
    # console.log $.inArray(votable.id, $scope.current_user_votes)
    if $.inArray(votable.id, $scope.current_user_votes) == -1
      false
    else
      true
]