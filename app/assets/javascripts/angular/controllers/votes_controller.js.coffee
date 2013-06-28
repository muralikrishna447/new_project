angular.module('ChefStepsApp').controller 'VotesController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->
  Poll = $resource('/polls/:id/show_as_json', {id:  $('#poll').data("poll-id")})
  $scope.poll = Poll.get()

  $scope.voteObject = (votable,index) ->
    votable_object = {}
    angular.forEach $scope.poll['poll_items'], (poll_item,index) ->
      if poll_item.id == votable.id
        votable_object = $scope.poll['poll_items'][index]

    url = '/votes?votable_type=' + 'PollItem' + '&votable_id=' + votable.id
    $http(
      method: 'POST'
      url: url
    ).success((data, status, headers, config) ->
      votable_object.votes_count +=1
      $scope.current_user_votes.push(votable.id)
    ).error((data, status, headers, config) ->

    )

  $scope.current_user_voted_for_this = (votable) ->
    if $.inArray(votable.id, $scope.current_user_votes) == -1
      false
    else
      true

]