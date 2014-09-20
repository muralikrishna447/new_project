@app.controller 'PlaygroundController', ['$scope', 'api.activity', ($scope, Activity) ->
  $scope.activities = Activity.query()
]