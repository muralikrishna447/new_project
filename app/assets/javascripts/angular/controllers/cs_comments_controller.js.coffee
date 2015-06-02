@app.run ['$http', '$q','$rootScope', 'csConfig', ($http, $q, $rootScope, csConfig) ->
  if typeof Bloom != 'undefined'
    Bloom.configure {
      apiKey: 'xchefsteps'
      auth: window.encryptedUser
      user: window.chefstepsUserId or null
      env: csConfig.bloom.env
    }
]
