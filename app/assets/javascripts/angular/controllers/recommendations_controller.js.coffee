@app.controller 'RecommendationsModalController', ["$scope", "$resource", "$http", "$modal", "$rootScope", ($scope, $resource, $http, $modal, $rootScope) ->
  unbind = {}
  undbind = $rootScope.$on 'openRecommendations', ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_recommendations.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      resolve:
        refinable: ->
          $scope.refinable
        recommendationType: ->
          $scope.recommendationType
      controller: 'RecommendationsController'
    )

  $scope.$on('$destroy', unbind)
]


@app.controller 'RecommendationsController', ['$scope', '$resource', '$modalInstance', '$controller', '$http', 'csGalleryService', 'ActivityMethods', 'refinable', '$rootScope', 'recommendationType', ($scope, $resource, $modalInstance, $controller, $http, csGalleryService, ActivityMethods, refinable, $rootScope, recommendationType) ->
  $scope.curated = []

  # $scope.Recommendation = $resource('/recommendations')
  # $scope.recommendations = $scope.Recommendation.query(->

  # )

  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resourceName = "Recommendation"
  $scope.resource = $scope.Recommendation
  $scope.objectMethods = ActivityMethods

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

  $scope.refine = ->
    # $rootScope.$broadcast 'refineRecommendations'
    $rootScope.$emit 'openSurvey'
    $modalInstance.close()
    mixpanel.track('Recommendations Refine Button Clicked')

  $scope.loadCurated = ->
    urls = [
      '/activities/coffee-butter-steak-and-spinach/as_json.json'
      '/activities/pomme-rosti/as_json.json'
      '/activities/fresh-pasta/as_json.json'
      '/activities/how-to-sharpen-a-knife/as_json.json'
      '/activities/perfect-yolks/as_json.json'
      '/activities/ultimate-roast-chicken/as_json.json'
    ]
    angular.forEach urls, (url) ->
      $http.get(url).success((data) ->
        $scope.curated.push(data)
      )
    $scope.recommendations = $scope.curated
    mixpanel.track('Recommendations Opened - Curated')

  $scope.loadRecommended = ->
    $scope.Recommendation = $resource('/recommendations')
    $scope.recommendations = $scope.Recommendation.query(->

    )
    mixpanel.track('Recommendations Opened - Recommended')

  $scope.loadList = () ->
    if recommendationType == 'curated'
      $scope.refinable = false
      $scope.loadCurated()
    else
      $scope.refinable = refinable
      $scope.loadRecommended()
]