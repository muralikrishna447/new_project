@app.controller 'BloomHotnessController', ["$scope", '$http', ($scope, $http) ->

  $http.get('https://server.usebloom.com/forum/posts?apiKey=xchefsteps&hosted=false&seen=&size=5&sort=hot').then (response) ->
    $scope.posts = response.data
  # console.log 'hey'
  # $scope.posts = "HELLO"
]
