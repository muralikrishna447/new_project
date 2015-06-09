@app.service 'bloomManager', ['$q', 'csConfig', '$window', ($q, csConfig, $window) ->

  # Single shared promise that gets resolved after Bloom is fully loaded
  # It is fine to hit bloom endpoints before this, like for getting comment counts
  # but you can't call anything on the Bloom object safely without using this.
  @deferred = $q.defer()
  @tagInserted = false

  @loadBloom = ->

    if ! @tagInserted
      # Don't do this right away - bloom is kinda slow to load, and we aren't at the comments
      # part of the page right away, wait until everything including images are loaded.
      @tagInserted = true
      $($window).load =>
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
