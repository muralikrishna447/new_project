angular.module('ChefStepsApp').directive 'csfixnakedlinks', ["$window", "$rootScope", ($window, $rootScope) ->

  restrict: 'A',
  replace: true,

  link:  (scope, element, attrs) ->
    $(element).on 'click', 'a', (event)->
      slug = event.currentTarget.href?.match('/activities/([^/]*)')?[1] 
      slug = event.currentTarget.href?.match('/classes/[^/].*/([^/]*)')?[1] if ! slug

      if slug 
        # Activity link
        # First try override for load directly in class frame...
        if ! scope.overrideLoadActivityBySlug?(slug)
          # ... otherwise show card
          $rootScope.$broadcast "showNellPopup", 
            resourceClass: 'Activity'
            include: '_activity_popup_card.html'
            slug: slug
        event.preventDefault()
        
      else 
        # Ingredient link
        slug = event.currentTarget.href?.match('/ingredients/([^/]*)')?[1]
        if slug
          $rootScope.$broadcast "showNellPopup", 
            resourceClass: 'Ingredient'
            include: '_ingredient_popup_card.html'
            slug: slug
          event.preventDefault()

      scope.$apply() if ! scope.$$phase
]
