angular.module('ChefStepsApp').controller 'VotingController', ["$scope", "$resource", "$location", ($scope, $resource, $location) ->
  # alert document.location.pathname + '/show_as_json'
  Poll = $resource(document.location.pathname + '/show_as_json')
  $scope.poll = Poll.query()
  console.log $scope.poll
]