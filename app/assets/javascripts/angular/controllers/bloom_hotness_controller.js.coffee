@app.controller 'BloomHotnessController', ["$scope", "csFilepickerMethods", "$http", ($scope, csFilepickerMethods, $http) ->

  $scope.posts = []

  $http.get('/whats-for-dinner').then (response) ->
    angular.forEach response.data, (item) ->
      # Use regexp instead of DOM nodes, b/c creating DOM nodes fetches the images,
      # which don't have the filepicker resize URL params in them.
      imageSrcMatch = item.content.match(/<img [^>]*src=["|\']([^"|\']+)/i)
      if imageSrcMatch
        item.image = imageSrcMatch[1]
        console.log "item image: ", item.image
        $scope.posts.push(item)

  $scope.postUrl = (post) ->
    "/forum/posts/#{post.slug}"

  $scope.track = (post) ->
    console.log('Bloom Hot Clicked')
]
