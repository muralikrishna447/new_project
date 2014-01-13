angular.module('ChefStepsApp').service 'csFacebook', [ "$rootScope", "$q", ($rootScope, $q) ->
  # Connects to facebook and authenticates then connects again to gather user's information.
  this.connect = ->
    deferred = $q.defer()
    FB.login( (response, event) ->
      if response.authResponse
        user = {
          name: null
          email: null
          access_token: null
          user_id: null
          provider: "facebook"
        }

        user.access_token = response.authResponse.accessToken
        user.user_id = response.authResponse.userID

        FB.api('/me', (profileResponse) ->
          $rootScope.$apply ->
            user.name = profileResponse.name
            user.email = profileResponse.email
            deferred.resolve(user)
        )
    , {scope: "email"})
    return deferred.promise

  # This gets a list of the person's friends and sorts them alphabetically
  # this.friends = ->
  #   deferred = $q.defer()
  #   FB.api('/me/friends', (response) ->
  #     $rootScope.$apply ->
  #       friends = response.data.sort (a,b) ->
  #         nameA = a.name.toLowerCase()
  #         nameB = b.name.toLowerCase()
  #         if (nameA < nameB)
  #           return -1
  #         if (nameA > nameB)
  #           return 1
  #         return 0
  #       _.each(friends, (friend) ->
  #         friend.value = false
  #       )
  #       deferred.resolve(friends)
  #   )
  #   return deferred.promise

  # This version uses the chefsteps styling
  # this.friendInvites = (friendIDs) ->
  #   deferred = $q.defer()
  #   FB.ui {
  #     method: 'apprequests'
  #     to: friendIDs
  #     title: 'ChefSteps Invite',
  #     message: 'Join me on ChefSteps a community cooking site',
  #   }, ->
  #     $rootScope.$apply ->
  #       deferred.resolve("success")
  #   return deferred.promise

  # This method doesn't use the chefsteps branded version of the friend selector.
  # this.friendInvites = ->
  #   deferred = $q.defer()
  #   FB.ui {
  #     method: 'apprequests',
  #     message: 'Come join me on ChefSteps, a social cooking site. '
  #   }, ->
  #     $rootScope.$apply ->
  #       deferred.resolve("sent")
  #   , ->
  #     $rootScope.$apply ->
  #       deferred.resolve("notSent")
  #   return deferred.promise

  this.friendInvites = ->
    deferred = $q.defer()
    FB.ui {
      method: 'send',
      link: 'http://www.chefsteps.com'
    }, ->
      $rootScope.$apply ->
        deferred.resolve("sent")
    , ->
      $rootScope.$apply ->
        deferred.resolve("notSent")
    return deferred.promise

  # this.friendInvites = ->
  #   deferred = $q.defer()
  #   FB.ui {
  #     method: 'feed',
  #     caption: 'Come join me on ChefSteps, a social cooking site. '
  #     link: "http://www.chefsteps.com"
  #   }, ->
  #     $rootScope.$apply ->
  #       deferred.resolve("sent")
  #   , ->
  #     $rootScope.$apply ->
  #       deferred.resolve("notSent")
  #   return deferred.promise

]