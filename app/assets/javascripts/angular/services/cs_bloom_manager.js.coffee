@app.service 'bloomManager', ['$q', 'csConfig', ($q, csConfig) ->

  # Single shared promise that gets resolved after Bloom is fully loaded
  # It is fine to hit bloom endpoints before this, like for getting comment counts
  # but you can't call anything on the Bloom object safely without using this.
  @deferred = $q.defer()
  @tagInserted = false

  @loadBloom = ->

    if ! @tagInserted
      @tagInserted = true
      script = document.createElement "script"
      script.type = "text/javascript"
      script.src = "#{csConfig.bloom.community_endpoint}/export/loader.js"
      script.async = true
      script.onload = =>
        Bloom.configure {
          apiKey: 'xchefsteps'
          auth: window.encryptedUser
          user: window.chefstepsUserId or null
          env: csConfig.bloom.env
        }
        @deferred.resolve()
      document.head.appendChild script

    @deferred.promise

  this
]
