# A/B Testing Directive
# Usage:
#
# %div(cs-abtest test-name="Test Name")
#   %div(cs-abtest-item)
#     Hi I am test item 1
#   %div(cs-abtest-item)
#     Hi I am test item 2

@app.directive 'csAbtest', ['localStorageService', '$rootScope', (localStorageService, $rootScope) ->
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
    testName = "Split Test: #{attrs.testName}"

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
    itemToBeShown.showItem = true if itemToBeShown
    $rootScope.splits[testName] = showIndex
]

@app.directive 'csAbtestItem', [ ->
  transclude: true
  require: '^csAbtest'
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs, csAbtest) ->
    csAbtest.addItem(scope)

    scope.$watch 'showItem', (newValue, oldValue) ->
      if typeof newValue == 'undefined'
        element.addClass 'ng-hide'

  template:
    """
      <div ng-transclude></div>
    """
]

# Only using this directive because transclude replace true is deprecated and we need that functionality for ab tests
@app.directive 'ngTranscludeReplace', [
  '$log'
  ($log) ->
    {
      terminal: true
      restrict: 'EA'
      link: ($scope, $element, $attr, ctrl, transclude) ->
        if !transclude
          $log.error 'orphan', 'Illegal use of ngTranscludeReplace directive in the template! ' + 'No parent directive that requires a transclusion found. '
          return
        transclude (clone) ->
          if clone.length
            $element.replaceWith clone
          else
            $element.remove()
          return
        return

    }
]
