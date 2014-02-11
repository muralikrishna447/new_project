@app.controller 'ProfileRecommendationsController', ["$scope", "$resource", "$http", "$modal", ($scope, $resource, $http, $modal) ->

  $scope.refinable = true

  $scope.openRecommendations = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_recommendations.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      resolve:
        refinable: ->
          $scope.refinable
      controller: 'RecommendationsModalController'
    )
    mixpanel.track('Recommendations Opened')

  $scope.openSurvey = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_survey.html"
      backdrop: false
      keyboard: false
      # windowClass: "takeover-modal"
      windowClass: "modal-fullscreen"
      controller: 'SurveyModalController'
    )
    mixpanel.track('Survey Opened')

  $scope.open = ->
    $scope.openRecommendations()

  $scope.$on 'refineRecommendations', (event, data) ->
    $scope.openSurvey()
]