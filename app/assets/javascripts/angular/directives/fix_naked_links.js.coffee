angular.module('ChefStepsApp').directive 'csfixnakedlinks', ["$window", ($window) ->

  restrict: 'A',
  replace: true,

  link:  (scope, element, attrs) ->
    $(element).on 'click', 'a', (event)->
      slug = event.currentTarget.href?.match('/activities/([^/]*)')?[1] 
      event.preventDefault() if slug && scope.overrideLoadActivityBySlug(slug)
      scope.$apply() if ! scope.$$phase
]
