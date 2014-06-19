@app.factory 'SiteSettings', ['$http', ($http) ->

  this.getSettings = ->
    $http.get("/settings").then (response) ->
      response.data

  this

]