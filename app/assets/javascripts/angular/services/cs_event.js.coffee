angular.module('ChefStepsApp').service 'cs_event', ['$http', ($http) ->
  this.track = (trackable_id, trackable_type, action) ->
    $http.post('/events', {'event': {'trackable_id': trackable_id, 'trackable_type': trackable_type, 'action': action}})

  this
]
