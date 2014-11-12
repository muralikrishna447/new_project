@app.controller 'BloomHotnessController', ["$scope", '$http', ($scope, $http) ->

  $scope.posts = []

  $http.get('/whats-for-dinner').then (response) ->
    angular.forEach response.data, (item) ->
      $scope.posts.push(item)

    # $http.get('hot').then (response) ->
    #   angular.forEach response.data, (item) ->
    #     $scope.posts.push(item)

  $scope.track = (post) ->
    mixpanel.track('Bloom Hot Clicked', {'title': post.title})
]
