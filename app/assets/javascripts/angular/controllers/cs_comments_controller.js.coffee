@app.run ['$http', '$q','$rootScope', 'csConfig', ($http, $q, $rootScope, csConfig) ->
  Bloom.configure {
    apiKey: 'xchefsteps'
    auth: window.encryptedUser
    user: window.chefstepsUserId or null
    env: csConfig.bloom_env
  }
]
