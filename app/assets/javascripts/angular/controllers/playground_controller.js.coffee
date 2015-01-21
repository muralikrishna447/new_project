@app.controller 'PlaygroundController', ['$scope', 'api.activity', '$sce', ($scope, Activity, $sce) ->

  $scope.activity = Activity.get({id: 'beef-tartare'})

  $scope.steps = [
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "1-Pick-Rosemary"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "2-Chop-Rosemary"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "4-Mix-Egg-White"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "9-Pull-Off-Meat"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "10-Clean-Bones"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "13-Cut-Strings"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "14-Tie-Roast"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "15-Brush-With-Egg"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "16-Coat-With-Rub"
    }
    {
      title: "Step 1"
      videoImage: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Q65LOSPyQaGveRepnyIY/convert?fit=max&w=600&quality=90&cache=true&rotate=exif"
      videoName: "17-Remove-Strings"
    }
  ]

]