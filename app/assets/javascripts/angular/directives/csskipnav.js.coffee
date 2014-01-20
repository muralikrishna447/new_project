@app.directive 'csskipnav', ["$window", ($window) ->
  restrict: 'A'

  link: (scope, elem, attrs) ->
    if $($window).width() <= 320 
      $(window).scrollTop(120)
]