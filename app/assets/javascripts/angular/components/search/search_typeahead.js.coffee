@components.directive 'searchTypeahead', ['AlgoliaSearchService', (AlgoliaSearchService) ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->
    scope.search = (query) =>
      params = {
        difficulty: 'any'
        generator: 'chefsteps'
        published_status: 'published'
        page: '1'
        search_all: query
      }

      AlgoliaSearchService.search(params).then (data) =>
        scope.searchResults = data
  templateUrl: '/client_views/component_search_typeahead.html'
]
