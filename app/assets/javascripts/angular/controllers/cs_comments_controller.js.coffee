@app.service 'BloomSettings', ['$q', 'csAuthentication', '$http', '$rootScope', ($q, csAuthentication, $http, $rootScope) ->
  window.csA = csAuthentication
  setUser = =>
    @loggedIn = csAuthentication.currentUser()?
    @user = ''+csAuthentication.currentUser().id if @loggedIn
    @token = csAuthentication.currentUser().authentication_token if @loggedIn
    $rootScope.$broadcast 'sessionChange'


    console.log 'logged in', @loggedIn, 'user', @user, 'token', @token

  $rootScope.$on 'login', => setUser()
  $rootScope.$on 'logout', => setUser()
  setUser()

  @getProfileLink = (user) => "/profiles/#{user.id}"
  @getAvatarUrl = =>
    "/notreal.png"
    
  @getUser = (id) =>
    def = $q.defer()

    $http.get('/users/' + id).success (data,status) ->
      data.avatarUrl = data['avatar_url']
      def.resolve data
   
    def.promise

  return this
]

@app.service 'Session', ['BloomSettings', (BloomSettings) ->
  @me = BloomSettings.user
  return this
]

@app.controller 'csCommentsController', ["$scope", ($scope) ->


]