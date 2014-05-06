@app.controller 'GiftRedemptionIndexController', ["$scope", ($scope) ->
  $scope.submitCode = ->
    url = "/gift/#{$scope.giftCode}"
    console.log("Loading " + url)
    window.location = url
]