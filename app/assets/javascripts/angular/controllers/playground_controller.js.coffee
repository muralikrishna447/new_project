@app.controller 'PlaygroundController', ['$scope', 'api.activity', '$sce', ($scope, Activity, $sce) ->

  $scope.activity = Activity.get({id: 'beef-tartare'})

  $scope.steps = [
    {
      title: "Step 1"
      imageUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-1.jpg"
      videoUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-1.mp4"
    }
    {
      title: "Step 2"
      imageUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-2.jpg"
      videoUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-2.mp4"
    }
    {
      title: "Step 3"
      imageUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-3.jpg"
      videoUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-3.mp4"
    }
    {
      title: "Step 4"
      imageUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-4.jpg"
      videoUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-4.mp4"
    }
  ]

]