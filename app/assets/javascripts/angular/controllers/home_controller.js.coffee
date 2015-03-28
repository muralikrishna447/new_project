@app.controller 'HomeManagerController', ['$scope', ($scope) ->
  @content = []
  return this
]

@app.controller 'ContainerCreatorController', ['$scope', ($scope) ->
  @submit = ->
    console.log @form

  return this
]

@app.controller 'HomeController', ['$scope', ($scope) ->
  @content = [
    {
      containerType: 'hero'
      source: 'http://localhost:3000/api/v0/activities/2434'
    }
    {
      containerType: 'standard'
      source: 'http://localhost:3000/api/v0/activities'
      numItems: 3
      itemType: 'standard'
    }
  ]

  return this

]

@app.directive 'csHero', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    csHero: '='
  }
  link: (scope, element, attrs) ->
    if scope.csHero.source
      $http.get(scope.csHero.source).success((data, status, headers, config) ->
        scope.content = data
        return
      ).error (data, status, headers, config) ->
        console.log data
        return

  template:
    """
      <div class='cs-hero'>
        <div class='cs-hero-content'>
          <div class='cs-hero-image'>
            <img ng-src='{{content.image}}'/>
          </div>
          <div class='cs-hero-cta'>
            <h2>{{content.title}}</h2>
            <button>Get the recipe</button
          </div>
        </div>
      </div>
    """
]

@app.directive 'csStandard', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    csStandard: '='
  }
  link: (scope, element, attrs) ->
    $http.get(scope.csStandard.source).success((data, status, headers, config) ->
      scope.content = data
      return
    ).error (data, status, headers, config) ->
      console.log data
      return

  templateUrl: '/client_views/container_standard.html'
]