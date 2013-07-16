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
      $('.alert-container').append("<div class='alert alert-error'><button class='close' data-dismiss='alert' type='button'>x</button><h4 class='alert-message'><a href='/sign_up'>Create an account</a> or <a href='/sign_in'>sign in</a> to vote for this.</h4><div class='lblock'></div></div>")
    )

  $scope.current_user_voted_for_this = (votable) ->
    if $.inArray(votable.id, $scope.current_user_votes) == -1
      false
    else
      true

  $scope.pollItemDetails = (current_poll_item) ->
    # current_poll_item.show_details = true
    angular.forEach $scope.poll['poll_items'], (poll_item) ->
      if current_poll_item.id == poll_item.id
        if poll_item.show_details
          poll_item.show_details = false
        else
          poll_item.show_details = true
      else
        poll_item.show_details = false
]