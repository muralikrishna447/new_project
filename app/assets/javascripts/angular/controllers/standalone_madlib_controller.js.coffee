@app.controller 'StandaloneMadlibController', ["$timeout", "$rootScope", 
($timeout, $rootScope) ->
  $timeout ( ->
    $rootScope.$broadcast('showPopupCTA')
  ), 5000
]

