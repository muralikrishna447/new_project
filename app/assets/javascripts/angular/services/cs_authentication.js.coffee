angular.module('ChefStepsApp').service 'csAuthentication', ->
  user = null
  current_user: ->
    user
  set_current_user: (user) ->
    user = user