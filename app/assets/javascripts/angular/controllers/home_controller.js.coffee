@app.controller 'HomeManagerController', ['$scope', ($scope) ->
  @content = []
  return this
]

@app.controller 'ContainerCreatorController', ['$scope', ($scope) ->
  oldCreator = {}
  @containerTypeOptions = [
    { name: 'hero', url: '/client_views/container_hero_form.html' }
    { name: 'standard', url: '/client_views/container_standard_form.html' }
  ]
  @submit = ->
    console.log @form

  return this
]

@app.service 'Preview', [ ->
  @setContainerType = (containerType) ->
    @containerType = containerType

  @getContainerType = ->
    @containerType

  return this
]

@app.controller 'PreviewController', ['$scope', ($scope) ->

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
      maxItems: 3
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
      console.log 'hero data: ', hero  
      return (scope, $element, $attrs) ->
        scope.content = {}
        switch hero.mode
          when 'api'
            if hero.source
              $http.get(hero.source).success((data, status, headers, config) ->
                scope.content.image = data.image
                scope.content.title = data.title
                return
              ).error (data, status, headers, config) ->
                console.log data
                return
          when 'custom'
            scope.content.image = hero.image
            scope.content.title = hero.title
        
        # All Modes
        scope.content.buttonMessage = hero.buttonMessage
        scope.content.targetURL = hero.targetURL

  template:
    """
      <div class='cs-hero'>
        <div class='cs-hero-content'>
          <div class='cs-hero-image'>
            <img ng-src='{{content.image}}'/>
          </div>
          <div class='cs-hero-cta'>
            <h2>{{content.title}}</h2>
            <a ng-href='{{content.targetURL}}' class='btn btn-primary'>{{content.buttonMessage}}</a>
          </div>
        </div>
      </div>
    """
]

@app.directive 'csStandard', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    maxItems: '@'
  }
  compile: (element, attrs) ->
    console.log 'csStandard attrs: ', attrs
    if attrs.csStandard && attrs.csStandard != '{{creator.form}}'
      standard = JSON.parse attrs.csStandard
      if standard.source
        return (scope, $element, $attrs) ->
          console.log 'maxItems: ', scope.maxItems
          $http.get(standard.source).success((data, status, headers, config) ->
            contentData = data
            if scope.maxItems
              contentData = contentData.slice(0, scope.maxItems)

            scope.content = contentData
            return
          ).error (data, status, headers, config) ->
            console.log data
            return

  templateUrl: '/client_views/container_standard.html'
]