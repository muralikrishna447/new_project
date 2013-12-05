angular.module('ChefStepsApp').service 'csAuthentication', ($rootScope) ->
  user = null
  this.currentUser = ->
    user
  this.setCurrentUser = (set_user) ->
    user = set_user
    $rootScope.$broadcast('login', {user: user})
  this.clearCurrentUser = ->
    user = null
    $rootScope.$broadcast('logout')
  this.loggedIn = ->
    !!user