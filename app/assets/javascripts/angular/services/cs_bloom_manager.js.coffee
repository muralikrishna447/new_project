@app.service 'bloomManager', ['$q', 'csConfig', '$window', ($q, csConfig, $window) ->

  # Single shared promise that gets resolved after Bloom is fully loaded
  # It is fine to hit bloom endpoints before this, like for getting comment counts
  # but you can't call anything on the Bloom object safely without using this.
  @deferred = $q.defer()
  @tagInserted = false

  @insertTag = ->
    @tagInserted = true
    console.log '$window loaded!!!!!'
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

  @loadBloom = =>
    console.log 'loadBloom started'
    console.log '@tagInserted: ', @tagInserted
    if ! @tagInserted
      console.log 'no tag inserted'
      console.log '$window: ', $window
      console.log 'document.readyState: ', document.readyState
      # Don't do this right away - bloom is kinda slow to load, and we aren't at the comments
      # part of the page right away, wait until everything including images are loaded.
      if document.readyState == 'complete'
        console.log 'document ready state is COMPLETE!!!'
        @insertTag()
      else
        $($window).load =>
          @insertTag()

    @deferred.promise

  this
]
