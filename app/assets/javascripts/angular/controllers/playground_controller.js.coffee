@app.controller 'PlaygroundController', ['$scope', 'api.activity', '$sce', ($scope, Activity, $sce) ->

  $scope.activity = Activity.get({id: 'beef-tartare'})

  $scope.steps = [
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "10-Clean-Bones"
    }
    {
      title: "Step 2"
      videoImage: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-2.jpg"
      videoName: "15-Cut-Extra-String"
    }
    {
      title: "Step 3"
      videoImage: "https://d92f495ogyf88.cloudfront.net/doneness/check-test-3.jpg"
      videoName: "2-Chop-Rosemary"
    }
  ]

]