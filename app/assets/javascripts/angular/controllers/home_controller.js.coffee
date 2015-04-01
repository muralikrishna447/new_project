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

# @app.directive 'csHero', ['$http', ($http) ->
#   restrict: 'A'
#   compile: (element, attrs) ->
#     console.log 'csHero attrs: ', attrs
#     if attrs.csHero && attrs.csHero != '{{creator.form}}'
#       hero = JSON.parse attrs.csHero
#       console.log 'hero data: ', hero  
#       return (scope, $element, $attrs) ->
#         scope.content = {}
#         switch hero.mode
#           when 'api'
#             if hero.source
#               $http.get(hero.source).success((data, status, headers, config) ->
#                 scope.content.image = data.image
#                 scope.content.title = data.title
#                 return
#               ).error (data, status, headers, config) ->
#                 console.log data
#                 return
#           when 'custom'
#             scope.content.image = hero.image
#             scope.content.title = hero.title
        
#         # All Modes
#         scope.content.buttonMessage = hero.buttonMessage
#         scope.content.targetURL = hero.targetURL

#   templateUrl: '/client_views/container_hero.html'
# ]

@app.directive 'csHero', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    csHero: '@'
  }
  controller: ['$scope', ($scope) ->
    $scope.content = {}
  ]
  link: (scope, $element, $attrs) ->
    scope.$watch 'csHero', (newValue, oldValue) ->
      # console.log 'newValue csHero: ', newValue
      # console.log 'oldValue csHero: ', oldValue
      if newValue != oldValue
        hero = JSON.parse(newValue)
        scope.content.buttonMessage = hero.buttonMessage
        scope.content.targetURL = hero.targetURL

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

  templateUrl: '/client_views/container_hero.html'
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