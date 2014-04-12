@app.constant('BloomAPIUrl', "http://production-bloom.herokuapp.com")
# @app.constant('BloomAPIUrl', "http://localhost:3000")
@app.constant('BloomAPIKey', "xchefsteps")
@app.constant('BloomData', window.encryptedUser)
console.log window.encryptedUser

@app.service 'BloomSettings', ['$q', 'csAuthentication', '$http', '$rootScope', ($q, csAuthentication, $http, $rootScope) ->
  console.log csAuthentication.currentUser()['id']
  window.csA = csAuthentication
  setUser = (reload) =>
    @loggedIn = csAuthentication.currentUser()?
    @user = ''+csAuthentication.currentUser().id if @loggedIn
    @token = csAuthentication.currentUser().authentication_token if @loggedIn
    $rootScope.$broadcast 'sessionChange'
    if reload
      window.location.reload()

    console.log 'logged in', @loggedIn, 'user', @user, 'token', @token

  $rootScope.$on 'login', => setUser(true)
  $rootScope.$on 'logout', => setUser(true)
  setUser()

  @getProfileLink = (user) => "/profiles/#{user.id}"
  @getAvatarUrl = =>
    "/notreal.png"
    
  @getUser = (id) =>
    def = $q.defer()
    if id?
      $http.get('/users/' + id).success (data,status) ->
        data.avatarUrl = data['avatar_url']
        def.resolve data
   
    def.promise

  @commentsIdToData = (id) =>
    def = $q.defer()

    $http.get("/comments/info?commentsId=#{id}").then (res) =>\
      def.resolve(res.data)

    def.promise

  return this
]

# @app.service 'Session', ['BloomSettings', (BloomSettings) ->
#   @me = BloomSettings.user
#   return this
# ]

@app.controller 'csCommentsController', ['$scope', '$resource', '$rootScope', ($scope, $resource, $rootScope) ->
  $scope.showModal = =>
    $rootScope.$broadcast 'openLoginModal'

]