@app.controller 'PlaygroundController', ['$scope', 'api.activity', '$sce', ($scope, Activity, $sce) ->

  $scope.activity = Activity.get({id: 'beef-tartare'})

  $scope.steps = [
    {
      title: "Step 1"
      imageUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-1.jpg"
      videoName: "10-Clean-Bones"
    }
    {
      title: "Step 2"
      imageUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-2.jpg"
      videoName: "15-Cut-Extra-String"
    }
    {
      title: "Step 3"
      imageUrl: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-3.jpg"
      videoName: "2-Chop-Rosemary"
    }
  ]

]