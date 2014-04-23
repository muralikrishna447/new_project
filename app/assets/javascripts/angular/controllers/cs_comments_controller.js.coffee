@app.run ['$http', '$q','$rootScope', ($http, $q, $rootScope) ->
  Bloom.configure {
    apiKey: 'xchefsteps'
    # bloomData: window.encryptedUser
    auth: window.encryptedUser
    user: window.chefstepsUserId or null
    on:
      login: ->
        $rootScope.$apply ->
          console.log 'someone clicked login'
          $rootScope.$emit 'openLoginModal'
    getUsers: (userIds) ->
      def = $q.defer()
      $http.get('/users?ids=' + userIds).then (res) ->
        users = res.data.map (user) ->
          user._id = user.id
          user.profileLink =  "/profiles/#{user._id}"
          user.avatarUrl = user['avatar_url']
          user
        console.log('users is ', users)
        def.resolve users

      def.promise
  }
]