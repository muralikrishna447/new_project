angular.module('ChefStepsApp').controller 'VotingController', ["$scope", "$resource", "$location", ($scope, $resource, $location) ->
  console.log document.location.pathname
  Poll = $resource(document.location.pathname + '/show_as_json.json')
  $scope.poll = Poll.query()
  console.log $scope.poll
]