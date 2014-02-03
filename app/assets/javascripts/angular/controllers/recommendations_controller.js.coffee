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
        Recommendation: -> $scope.Recommendation 
        recommendations: -> $scope.recommendations
      controller: 'RecommendationsModalController'
    )
]


@app.controller 'RecommendationsModalController', ['$scope', '$modalInstance', '$controller', 'csGalleryService', 'Recommendation', 'recommendations', 'ActivityMethods', ($scope, $modalInstance, $controller, csGalleryService, Recommendation, recommendations, ActivityMethods) ->
  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resourceName = "Recommendation"
  $scope.resource = Recommendation
  $scope.objectMethods = ActivityMethods

  $scope.recommendations = recommendations
  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
]