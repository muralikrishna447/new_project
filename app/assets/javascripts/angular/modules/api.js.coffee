@api = angular.module 'cs.api', [ ->
]

@app.factory 'api.activity', [ '$resource', ($resource) ->
  $resource '/api/v0/activities/:id', { id: '@id' }
]