angular.module('ChefStepsApp').service 'csAuthentication', ($rootScope) ->
  user = null
  this.currentUser = ->
    user
  this.setCurrentUser = (set_user) ->
    user = set_user
    $rootScope.$broadcast('login');
  this.loggedIn = ->
    !!user