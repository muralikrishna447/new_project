@app.run ['$http', '$q','$rootScope', ($http, $q, $rootScope) ->
  Bloom.configure {
    env: 'staging'
    apiKey: 'xchefsteps'
    auth: window.encryptedUser
    user: window.chefstepsUserId or null
    getUsers: (userIds, callback) ->
      $http.get('/users?ids=' + userIds).then (res) ->
        users = res.data.map (user) ->
          user._id = "" + user.id
          user.profileLink =  "http://www.chefsteps.com/profiles/#{user.slug}"
          user.avatarUrl = user['avatar_url']
          user

        callback(users)
      return undefined
  }
]