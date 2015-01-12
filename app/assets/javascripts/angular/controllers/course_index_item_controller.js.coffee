@app.controller 'CourseIndexItemController', ['$scope', ($scope) ->

  $scope.free = -> 
    $scope.discounted_price == 0

  $scope.discounted = ->
    $scope.assembly.price > $scope.discounted_price

  $scope.priceLabel = ->
    if $scope.discounted() then "REGULAR PRICE" else "PRICE"

]