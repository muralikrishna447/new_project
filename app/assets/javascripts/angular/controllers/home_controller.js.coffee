@app.controller 'HomeManagerController', ['$scope', ($scope) ->
  @content = []
  return this
]

@app.controller 'ContainerCreatorController', ['$scope', ($scope) ->
  @containerTypeOptions = [
    { name: 'hero', url: '/client_views/container_hero_form.html' }
    { name: 'standard', url: '/client_views/container_standard_form.html' }
  ]
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

@app.directive 'preview', ['$compile', ($compile) ->
  scope: {
    preview: '='
  }
  link: (scope, element, attr) ->
    scope.$watch 'preview', ((newValue, oldValue) ->
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue
      $compile(element.contents())(scope)
    ), true
]

# @app.directive 'csHero', ['$http', ($http) ->
#   restrict: 'A'
#   scope: {
#     csHero: '@'
#   }
#   link: (scope, element, attrs) ->
#     if scope.csHero.source
#       $http.get(scope.csHero.source).success((data, status, headers, config) ->
#         scope.content = data
#         return
#       ).error (data, status, headers, config) ->
#         console.log data
#         return

#   template:
#     """
#       <div class='cs-hero'>
#         <div class='cs-hero-content'>
#           <div class='cs-hero-image'>
#             <img ng-src='{{content.image}}'/>
#           </div>
#           <div class='cs-hero-cta'>
#             <h2>{{content.title}}</h2>
#             <button>Get the recipe</button
#           </div>
#         </div>
#       </div>
#     """
# ]

@app.directive 'csHero', ['$http', ($http) ->
  restrict: 'A'
  compile: (element, attrs) ->
    console.log 'csHero attrs: ', attrs
    if attrs.csHero && attrs.csHero != '{{creator.form}}'
      hero = JSON.parse attrs.csHero
      if hero.source
        return (scope, $element, $attrs) ->
          $http.get(hero.source).success((data, status, headers, config) ->
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