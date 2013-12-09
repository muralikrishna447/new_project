angular.module('ChefStepsApp').service 'csAuthentication', [ "$rootScope", ($rootScope) ->
  user = null
  this.currentUser = ->
    user
  this.setCurrentUser = (set_user) ->
    set_user = $.parseJSON(set_user) if typeof(set_user) == "string"
    user = set_user
    $rootScope.$broadcast('login', {user: user})
  this.clearCurrentUser = ->
    user = null
    $rootScope.$broadcast('logout')
  this.loggedIn = ->
    !!user
]