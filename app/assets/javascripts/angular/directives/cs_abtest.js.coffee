# A/B Testing Directive
# Usage:
#
# %div(cs-abtest test-name="Test Name")
#   %div(cs-abtest-item)
#     Hi I am test item 1
#   %div(cs-abtest-item)
#     Hi I am test item 2

@app.directive 'csAbtest', ['localStorageService', (localStorageService) ->
  restrict: 'A'
  scope: {
    testName: '@'
  }
  controller: ['$scope', ($scope) ->
    $scope.items = []

    addItem: (item)->
      $scope.items.push item
  ]
  link: (scope, element, attrs) ->
    testName = attrs.testName

    # If user has visited the page, make sure they see the same test when the revisit the same page
    localItem = localStorageService.get(testName)
    if localItem
      console.log "Local item found"
      showIndex = localItem
    else
      console.log "Local item not found"
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
    scope.content = angular.element(element).children().html()
    csAbtest.addItem(scope)

  template:
    """
      <div ng-transclude ng-show="showItem"></div>
    """
]