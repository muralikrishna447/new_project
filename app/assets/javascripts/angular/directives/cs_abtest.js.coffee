@app.directive 'csAbtest', ['localStorageService', (localStorageService) ->
  restrict: 'A'
  scope: {
    testName: '='
  }
  controller: ['$scope', ($scope) ->
    $scope.items = []

    addItem: (item)->
      $scope.items.push item
  ]
  link: (scope, element, attrs) ->
    testName = attrs.testName
    localItem = localStorageService.get(testName)
    if localItem
      showIndex = localItem
    else
      showIndex = _.random 0, (scope.items.length - 1)
      localStorageService.add(testName, showIndex)

    itemToBeShown = scope.items[showIndex]
    itemToBeShown.showItem = true
    mixpanel.track "AB Test: #{attrs.testName}", {index: showIndex, content: itemToBeShown.content}

]

@app.directive 'csAbtestItem', [ ->
  transclude: true
  require: '^csAbtest'
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs, csAbtest) ->
    scope.content = angular.element(element).text()
    csAbtest.addItem(scope)

  template:
    """
      <div ng-transclude ng-show="showItem"></div>
    """
]