@app.controller 'BloomHotnessController', ["$scope", '$http', ($scope, $http) ->

  $scope.posts = []

  $http.get('https://server.usebloom.com/forum/posts?apiKey=xchefsteps&categoryId=7fc5373b-ed4e-43bd-acdc-10591eb205a0&hosted=false&seen=&size=3&sort=hot').then (response) ->
    angular.forEach response.data, (item) ->
      $scope.posts.push(item)

    $http.get('https://server.usebloom.com/forum/posts?apiKey=xchefsteps&hosted=false&seen=&size=3&sort=hot').then (response) ->
      angular.forEach response.data, (item) ->
        $scope.posts.push(item)

  $scope.track = (post) ->
    mixpanel.track('Bloom Hot Clicked', {'title': post.title})
]
