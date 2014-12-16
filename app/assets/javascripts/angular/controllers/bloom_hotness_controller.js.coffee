@app.controller 'BloomHotnessController', ["$scope", "csFilepickerMethods", "$http", ($scope, csFilepickerMethods, $http) ->

  $scope.posts = []

  $http.get('/whats-for-dinner').then (response) ->
    angular.forEach response.data, (item) ->
      content = angular.element item.content
      images = content.find('img')
      if images.length > 0
        item.image = images[0].src
        console.log "item image: ", item.image
        $scope.posts.push(item)

    # $http.get('hot').then (response) ->
    #   angular.forEach response.data, (item) ->
    #     $scope.posts.push(item)

  $scope.postUrl = (post) ->
    "/forum/posts/#{post.slug}"

  $scope.track = (post) ->
    mixpanel.track('Bloom Hot Clicked', {'title': post.title})
]
