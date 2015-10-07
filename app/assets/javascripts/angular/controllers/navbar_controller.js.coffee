@app.controller 'NavController', ['$scope', '$window', 'csAuthentication', ($scope, $window, csAuthentication) ->

  @authentication = csAuthentication.currentUser()

  this
]
