@app.run ['$http', '$q','$rootScope', ($http, $q, $rootScope) ->
  # bloomEncrypt = (string, key) ->
  #   console.log 'got encrypted'
  #   encryptedResponse = null
  #   $http.get('http://api.usebloom.com/encrypt?string=' + string + '&apiKey=' + key).then (res) ->
  #     encryptedResponse = res.data
  #   $http.get('http://api.usebloom.com/decrypt?string=' + encryptedResponse + '&apiKey=' + key).then (res) ->
  #     console.log res.data
  # encrypted = bloomEncrypt({"userId": "7698"}, 'xchefsteps')

  Bloom.configure {
    apiKey: 'xchefsteps'
    # bloomData: window.encryptedUser
    auth: window.encryptedUser
    # auth: 'U2FsdGVkX18ZXzDf7IKHPgN6Ih/1V5+eDZAAoiyE70eZcKkXrHfi4OjEUfeO9QY8'
    # auth: ->
    #   $http.get('http://api.usebloom.com/encrypt?string=hi&apiKey=xchefsteps').then (res) ->
    #     return res.data
    # auth: ->
    #   def = $q.defer()
    #   $http.get('http://api.usebloom.com/encrypt?string=hi&apiKey=xchefsteps').then (res) ->
    #     encrypted = res.data
    #     def.resolve encrypted
    #   def.promise
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