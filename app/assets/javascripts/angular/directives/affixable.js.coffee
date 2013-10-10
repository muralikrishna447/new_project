angular.module('ChefStepsApp').directive 'affixable', ["$window", ($window) ->
  restrict: 'A'
  controller: ['$scope', '$window', ($scope, $window) ->
    $scope.setAffixable = (elem,offset) ->
      if $($window).scrollTop() >= offset
        elem.addClass('affixable-fixed')
      else
        elem.removeClass('affixable-fixed')
  ]

  link: (scope, elem, attrs) ->
    offset = attrs.affixable
    $($window).scroll ->
      scope.setAffixable(elem,offset)

    $($window).hammer({drag_min_distance: 1}).on 'drag', (e) ->
      scope.setAffixable(elem,offset)
      e.preventDefault()

    $($window).hammer().on 'swipe', (e) ->
      scope.setAffixable(elem,offset)
      e.preventDefault()

    $($window).hammer().on 'scroll', (e) ->
      scope.setAffixable(elem,offset)

    $($window).resize ->
      scope.setAffixable(elem,offset)
]