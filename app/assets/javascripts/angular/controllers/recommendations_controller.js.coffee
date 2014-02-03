@app.controller 'RecommendationsController', ["$scope", "$resource", "$http", "$modal", ($scope, $resource, $http, $modal) ->

  $scope.Recommendation = $resource('/recommendations')
  $scope.recommendations = $scope.Recommendation.query(->

  )

  $scope.open = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_recommendations.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      resolve: 
        recommendations: -> $scope.recommendations
      controller: 'RecommendationsModalController'
    )
]


@app.controller 'RecommendationsModalController', ['$scope', '$modalInstance', '$http', 'recommendations', ($scope, $modalInstance, $http, recommendations) ->
  console.log recommendations
  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
]