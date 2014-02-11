@app.controller 'RecommendationsController', ["$scope", "$resource", "$http", "$modal", ($scope, $resource, $http, $modal) ->

  $scope.open = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_recommendations.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      controller: 'RecommendationsModalController'
    )
]


@app.controller 'RecommendationsModalController', ['$scope', '$resource', '$modalInstance', '$controller', '$http', 'csGalleryService', 'ActivityMethods', 'refinable', '$rootScope', ($scope, $resource, $modalInstance, $controller, $http, csGalleryService, ActivityMethods, refinable, $rootScope) ->
  $scope.curated = []
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
    mixpanel.track('Recommendations Refine Button Clicked')

  $scope.loadCurated = ->
    urls = [
      '/activities/sous-vide-steak/as_json.json'
      '/activities/pomme-rosti/as_json.json'
      '/activities/molten-chocolate-souffle/as_json.json'
      '/activities/how-to-sharpen-a-knife/as_json.json'
      '/activities/perfect-yolks/as_json.json'
      '/activities/ultimate-roast-chicken/as_json.json'
    ]
    angular.forEach urls, (url) ->
      $http.get(url).success((data) ->
        $scope.curated.push(data)
      )
    mixpanel.track('Recommendations Opened - Curated')

  $scope.trackRecommended = ->
    mixpanel.track('Recommendations Opened - Recommended')
]