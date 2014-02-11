@app.controller 'RecommendationsController', ["$scope", "$resource", "$http", "$modal", ($scope, $resource, $http, $modal) ->

  $scope.open = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_recommendations.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      controller: 'RecommendationsModalController'
    )
    mixpanel.track('Recommendations Opened')
]


@app.controller 'RecommendationsModalController', ['$scope', '$resource', '$modalInstance', '$controller', 'csGalleryService', 'ActivityMethods', 'refinable', '$rootScope', ($scope, $resource, $modalInstance, $controller, csGalleryService, ActivityMethods, refinable, $rootScope) ->
  $scope.refinable = refinable

  $scope.Recommendation = $resource('/recommendations')
  $scope.recommendations = $scope.Recommendation.query(->

  )

  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resourceName = "Recommendation"
  $scope.resource = $scope.Recommendation
  $scope.objectMethods = ActivityMethods

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

  $scope.refine = ->
    $rootScope.$broadcast 'refineRecommendations'
    $modalInstance.close()
]