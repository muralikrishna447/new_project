@app.controller 'GiftRedemptionIndexController', ["$scope", ($scope) ->
  $scope.submitCode = ->
    url = "http://chefsteps.com/gift/#{$scope.giftCode}"
    console.log("Loading " + url)
    window.location = url
]