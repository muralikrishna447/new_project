@app.controller 'ConnectModalController', ['$scope', '$http', '$modal', '$rootScope', 'csDataLoading', ($scope, $http, $modal, $rootScope, csDataLoading) ->
  unbind = {}
  unbind = $rootScope.$on 'openConnect', (event, data) ->
    console.log 'OPEN CONNECT'
    csDataLoading.setFullScreen(true)
    modalInstance = $modal.open(
      templateUrl: "/client_views/_connect.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      resolve:
        intent: ->
          data.intent if data
      controller: 'ConnectController'
    )
    mixpanel.track('Connect Opened')

  $scope.$on('$destroy', unbind)
]

@app.controller 'ConnectController', ['$scope', '$modalInstance', '$http', '$rootScope', 'intent', 'csDataLoading', ($scope, $modalInstance, $http, $rootScope, intent, csDataLoading) ->
  $scope.close = ->
    $modalInstance.close()
    csDataLoading.setFullScreen(false)

  $rootScope.$on 'closeConnectFromFtue', ->
    $modalInstance.close()
]