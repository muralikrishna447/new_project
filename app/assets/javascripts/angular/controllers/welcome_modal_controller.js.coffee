@app.controller 'WelcomeModalController', ['$scope', '$http', '$modal', '$rootScope', ($scope, $http, $modal, $rootScope) ->
  unbind = {}
  unbind = $rootScope.$on 'openWelcome', (event, data) ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_welcome.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      resolve:
        intent: ->
          data.intent if data
      controller: 'WelcomeController'
    )
    mixpanel.track('Welcome Opened')

  $scope.$on('$destroy', unbind)
]

@app.controller 'WelcomeController', ['$scope', '$modalInstance', '$http', '$rootScope', 'intent', ($scope, $modalInstance, $http, $rootScope, intent) ->
  $scope.close = ->
    $modalInstance.close()

  $rootScope.$on 'closeWelcomeFromFtue', ->
    $modalInstance.close()
]


