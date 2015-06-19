@components.directive 'searchTypeahead', ['AlgoliaSearchService', (AlgoliaSearchService) ->
  restrict: 'A'
  scope: {
    customMethod: '@'
    select: '&onSelect'
  }
  link: (scope, element, attrs) ->

    scope.search = (query) =>
      params = {
        difficulty: 'any'
        generator: 'chefsteps'
        published_status: 'published'
        page: '1'
        search_all: query
        attributesToRetrieve: 'title,url,image,likes_count,description'
      }

      AlgoliaSearchService.search(params).then (data) =>
        scope.searchResults = data

    scope.clear = ->
      console.log 'clearing'
      scope.searchQuery = null
      scope.searchResults = []

  templateUrl: '/client_views/component_search_typeahead.html'
]
