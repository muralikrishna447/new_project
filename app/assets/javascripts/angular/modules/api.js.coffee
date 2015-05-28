@api = angular.module 'cs.api', [ ->
]

@app.factory 'api.activity', [ '$resource', ($resource) ->
  $resource '/api/v0/activities/:id',
    { id: '@id' },
]

# Unpreferred, calls CS server, use Algolia methods below instead
@app.factory 'api.search', [ '$resource', ($resource) ->
  $resource '/api/v0/search', { query: { method: 'GET', isArray: true } }
]

# I'm undecided whether I love this here or in its own module. It is a CS API
# but lives on another service. Giving this an ugly name to avoid conflicts
# with the algolia global JS.
@app.service 'AlgoliaSearchService', ["csConfig", "$q", (csConfig, $q) ->

  # Search-only API key, safe to distribute
  algolia = algoliasearch('JGV2ODT81S', '890e558aa5ce0acb553f4d251add31cb')

  # Algolia doesn't let you change sort order within an index at query time, instead
  # you use slave indices for each of your sorts.
  indices =
    'relevance' : algolia.initIndex("ChefSteps_#{csConfig.env}")
    'oldest' :  algolia.initIndex("ChefStepsOldest_#{csConfig.env}")
    'newest' : algolia.initIndex("ChefStepsNewest_#{csConfig.env}")
    'popular' : algolia.initIndex("ChefStepsPopular_#{csConfig.env}")

  # For compatability, this accepts the same entries in params as
  # the pre-existing website search API and does any massaging needed
  # to pass them to Algolia.
  @search = (params) ->
    # Choose the index that has the sort we want, defaulting to the master (relevance) sort
    index = indices[params['sort']?.toLowerCase()] || indices["relevance"]

    # Translate these boolean filters to numeric
    chefstepsGenerated = if params['generator'].toLowerCase() == 'chefsteps' then 1 else 0
    published = if params['published_status'].toLowerCase() == 'published' then 1 else 0

    # Difficulty is handled as a facet instead of a filter, because there aren't string filters
    facetFilters = []
    facetFilters.push("difficulty:#{params['difficulty'].toLowerCase()}") if params['difficulty'].toLowerCase() != 'any'

    # If there is a tag filter but no search string, use the tag as the search
    # string as well. That won't affect the results (since tags are also searched),
    # but it gives a much better ordering.
    searchTerm = params['search_all'] || params['tag']

    deferred = $q.defer()
    index.search(searchTerm,
      {
        hitsPerPage: 12
        page: params['page'] - 1
        numericFilters: [
          "chefsteps_generated=#{chefstepsGenerated}"
          "published=#{published}"
        ]
        tagFilters: params['tag'] || ''
        facetFilters: facetFilters
        facets: '*'
        advancedSyntax: true
        attributesToRetrieve: "title,url,image,likes_count"
        attributesToHighlight: ""
        attributesToSnippet: ""
      },
      (success, hits) ->
        deferred.resolve(hits.hits)
      , (reason) ->
        deferred.reject(reason)
    )
    deferred.promise

  this
]