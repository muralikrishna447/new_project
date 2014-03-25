@app.controller 'RecommendationsModalController', ["$scope", "$resource", "$http", "$modal", "$rootScope", ($scope, $resource, $http, $modal, $rootScope) ->
  unbind = {}
  unbind = $rootScope.$on 'openRecommendations', (event, data) ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_recommendations.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      resolve:
        refinable: ->
          $scope.refinable
        recommendationType: ->
          $scope.recommendationType
        intent: ->
          if data
            data.intent
      controller: 'RecommendationsController'
    )
    mixpanel.track('Recommendations Opened')

  $scope.$on('$destroy', unbind)
]


@app.controller 'RecommendationsController', ['$scope', '$resource', '$controller', '$http', 'csGalleryService', 'ActivityMethods', '$rootScope', ($scope, $resource, $controller, $http, csGalleryService, ActivityMethods, $rootScope) ->
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
    if intent == 'ftue'
      csFtue.next()

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
    $scope.loadRecommended()
    # if recommendationType == 'curated'
    #   $scope.refinable = false
    #   $scope.loadCurated()
    # else
    #   $scope.refinable = refinable
    #   $scope.loadRecommended()

  $rootScope.$on 'closeRecommendationsFromFtue', ->
    console.log 'closed recommendations from ftue'
]

@app.directive 'csRecommendationsModal', [ ->
  restrict: 'E'
  controller: 'RecommendationsController'
  link: (scope, element, attrs) ->
  templateUrl: '/client_views/_recommendations.html'
]