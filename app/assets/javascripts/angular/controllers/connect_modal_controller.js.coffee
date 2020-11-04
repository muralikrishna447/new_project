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

  $scope.$on('$destroy', unbind)
]

@app.controller 'ConnectController', ['$scope', 'csDataLoading', ($scope, csDataLoading) ->
  $scope.close = ->
    csDataLoading.setFullScreen(false)

]

@app.directive 'csConnectModal', [ ->
  restrict: 'E'
  controller: 'ConnectController'
  link: (scope, element, attrs) ->
  templateUrl: '/client_views/_connect.html'
]
