@app.controller 'ConnectModalController', ['$scope', '$http', '$modal', '$rootScope', ($scope, $http, $modal, $rootScope) ->
  unbind = {}
  unbind = $rootScope.$on 'openConnect', (event, data) ->
    console.log 'OPEN CONNECT'
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

@app.controller 'ConnectController', ['$scope', '$modalInstance', '$http', '$rootScope', 'intent', ($scope, $modalInstance, $http, $rootScope, intent) ->
  $scope.close = ->
    $modalInstance.close()

  $rootScope.$on 'closeConnectFromFtue', ->
    $modalInstance.close()
]