@app.directive 'csBanner', [ ->
  controller: ['$scope', ($scope) ->
    $scope.dismissed = false
    close: ->
      console.log 'Closing Banner'
      $scope.dismissed = true
      $scope.$apply()
  ]

]

@app.directive 'csBannerClose', [ ->
  require: '^csBanner'
  link: (scope, element, attrs, csBannerCtrl) ->
    element.on 'click', ->
      csBannerCtrl.close()

]