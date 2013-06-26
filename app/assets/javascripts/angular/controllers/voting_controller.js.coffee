angular.module('ChefStepsApp').controller 'VotingController', ["$scope", "$resource", "$location", ($scope, $resource, $location) ->
  Poll = $resource(document.location.pathname + '/show_as_json')
  $scope.poll = Poll.query()
]