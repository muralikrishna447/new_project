@app.run ['$http', '$q','$rootScope', ($http, $q, $rootScope) ->
  Bloom.configure {
    apiKey: 'xchefsteps'
    auth: window.encryptedUser
    user: window.chefstepsUserId or null
    env: 'production'
  }
]