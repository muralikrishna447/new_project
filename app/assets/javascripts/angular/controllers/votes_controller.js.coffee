angular.module('ChefStepsApp').controller 'VotesController', ["$scope", "$resource", "$http", "$timeout", ($scope, $resource, $http, $timeout) ->
  Poll = $resource('/polls/:id/show_as_json', {id:  $('#poll').data("poll-id")})
  $scope.poll = Poll.get(->
    $scope.hideSpinner = true
  )

  $scope.socialURL = ->
    "https://www.chefsteps.com/polls/" + $scope.poll.slug

  $scope.userImageUrl = (image_id) ->
    if image_id
      image = JSON.parse(image_id)
      window.cdnURL(image.url + '/convert?fit=crop&w=30&h=30&cache=true')
    else
      window.cdnURL('https://www.filepicker.io/api/file/yklhkH0iRV6biUOcXKSw/convert?fit=crop&w=30&h=30&cache=true')

  $scope.current_user_voted = ->
    voted = false
    angular.forEach $scope.poll['poll_items'], (poll_item,index) ->
      if $scope.current_user_voted_for_this(poll_item)
        voted = true
    return voted

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