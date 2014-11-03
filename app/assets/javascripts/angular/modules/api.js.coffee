@api = angular.module 'cs.api', [ ->
]

@app.factory 'api.activity', [ '$resource', ($resource) ->
  $resource '/api/v0/activities/:id', { id: '@id' }
]

@app.factory 'api.search', [ '$resource', ($resource) ->
  $resource '/api/v0/search', { query: { method: 'GET', isArray: true } }
]