angular.module('ChefStepsApp').controller 'PollItemController', ["$scope", "$timeout", "$http", ($scope, $timeout, $http) ->

  $scope.init = (poll_status) ->
    $scope.poll_status = poll_status

  $scope.voteObjectGuts = (dir) ->
    votable_object = $scope.poll_item

    url = '/votes?votable_type=' + 'PollItem' + '&votable_id=' + votable_object.id + "&dir=" + dir
    $http(
      # See comment in rails create action for this
      method: 'POST'
      url: url
    ).success((data, status, headers, config) ->
      votable_object.votes_count += dir
      if dir > 0
        $scope.current_user_votes.push(votable_object.id)
        $scope.expandSocial()
      else
        $scope.current_user_votes.splice($scope.current_user_votes.indexOf(votable_object.id), 1)
    ).error((data, status, headers, config) ->
      if $('#voterwarning').length == 0
        $('.alert-container').append("<div class='alert alert-error' id='voterwarning'><button class='close' data-dismiss='alert' type='button'>x</button><h4 class='alert-message'><a href='/sign_up'>Create an account</a> or <a href='/sign_in'>sign in</a> to vote for this.</h4><div class='lblock'></div></div>")
    )

  $scope.voteObject = ->
    unless $scope.poll_status == 'Closed'
      $scope.voteObjectGuts(1)

  $scope.unvoteObject = ->
    unless $scope.poll_status == 'Closed'
      $scope.voteObjectGuts(-1)


  $scope.expandSocial =  ->
    $timeout (->
      $scope.videoDurationExceeded = true
      $scope.$broadcast('expandSocialButtons')
    ), 1500

  $scope.socialTitle = ->
    $scope.poll_item.title

  $scope.socialMediaItem = ->
    null

  $scope.tweetMessage = ->
    "Vote for"

  $scope.emailSubject = ->
    "Vote for " + $scope.socialTitle()

  $scope.emailBody = ->
    "Hey, will you come vote for " + $scope.socialTitle() + " at ChefSteps.com? Here's the link: " + $scope.socialURL()

]