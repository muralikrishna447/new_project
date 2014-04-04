angular.module('ChefStepsApp').directive 'csfixnakedlinks', ["$window", "$rootScope", ($window, $rootScope) ->

  restrict: 'A',
  replace: true,

  link:  (scope, element, attrs) ->
    $(element).on 'click', 'a', (event)->
      slug = event.currentTarget.href?.match('/activities/([^/]*)')?[1] 
      slug = event.currentTarget.href?.match('/classes/[^/].*/([^/]*)')?[1] if ! slug
      event.preventDefault() if slug && scope.overrideLoadActivityBySlug?(slug)

      slug = event.currentTarget.href?.match('/ingredients/([^/]*)')?[1]
      if slug
        $rootScope.$broadcast "showNellPopup", 
          resourceClass: 'Ingredient'
          include: '_ingredient_card.html'
          slug: slug
        event.preventDefault()

      scope.$apply() if ! scope.$$phase
]
