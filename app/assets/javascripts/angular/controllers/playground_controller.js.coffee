@app.controller 'PlaygroundController', ['$scope', 'api.activity', ($scope, Activity) ->

  $scope.activity = Activity.get({id: 'beef-tartare'})

    
]