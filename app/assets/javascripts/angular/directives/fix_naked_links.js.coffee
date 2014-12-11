angular.module('ChefStepsApp').directive 'csfixnakedlinks', ["$window", "$rootScope","$location", "$anchorScroll", "$http", ($window, $rootScope, $location, $anchorScroll, $http) ->

  restrict: 'A',
  replace: true,

  link:  (scope, element, attrs) ->
    $(element).on 'click', 'a', (event)->

      slug = event.currentTarget.href?.match('/activities/([^/]*)')?[1] 
      slug = event.currentTarget.href?.match('/classes/[^/].*/([^/]*)')?[1] if ! slug

      # allow for anchor links
      currentBaseUrl = $location.absUrl().split('#')[0]
      targetBaseUrl = event.currentTarget.baseURI
      if currentBaseUrl == targetBaseUrl && event.currentTarget.hash.length > 0
        id = event.currentTarget.hash.replace('#','')
        $location.hash(id)
        $anchorScroll()
        return

      # First try override for load directly in class frame...
      if slug && scope.overrideLoadActivityBySlug?(slug)
        event.preventDefault()
        return

      # We should really make this work in reverse and not override default link behavior.  Explicitly specificy which links open a nell card.
      return if $(event.currentTarget).attr('no-nell-popup')
 
      if slug 
        # Activity link, show card
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