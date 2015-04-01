@app.controller 'HomeManagerController', ['$scope', ($scope) ->
  @content = []
  @add = (container) ->
    @content.push container
    container = {}
    console.log @content
  return this
]

@app.controller 'ContainerCreatorController', ['$scope', ($scope) ->
  oldCreator = {}

  @showForm = false
  @form = {}

  @containerTypeOptions = [
    { name: 'hero', url: '/client_views/container_hero_form.html' }
    { name: 'standard', url: '/client_views/container_standard_form.html' }
  ]

  @toggleForm = ->
    console.log "Toggle Form"
    @showForm = ! @showForm

  @submit = ->
    console.log @form
    @showForm = false

  @clear = ->
    @form = {}

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
    csStandard: '@'
  }
  link: (scope, $element, $attrs) ->
    scope.content = {}
    scope.$watch 'csStandard', (newValue, oldValue) ->
      if newValue != oldValue
        standard = JSON.parse(newValue)
        console.log 'standard: ', standard
        switch standard.mode
          when 'api'
            $http.get(standard.source).success((data, status, headers, config) ->
              contentData = data
              if standard.maxItems
                contentData = contentData.slice(0, standard.maxItems)

              scope.content = contentData
              return
            ).error (data, status, headers, config) ->
              console.log data
              return

  templateUrl: '/client_views/container_standard.html'
]

# @app.directive 'csStandard', ['$http', ($http) ->
#   restrict: 'A'
#   scope: {
#     maxItems: '@'
#   }
#   compile: (element, attrs) ->
#     console.log 'csStandard attrs: ', attrs
#     if attrs.csStandard && attrs.csStandard != '{{creator.form}}'
#       standard = JSON.parse attrs.csStandard
#       if standard.source
#         return (scope, $element, $attrs) ->
#           console.log 'maxItems: ', scope.maxItems
#           $http.get(standard.source).success((data, status, headers, config) ->
#             contentData = data
#             if scope.maxItems
#               contentData = contentData.slice(0, scope.maxItems)

#             scope.content = contentData
#             return
#           ).error (data, status, headers, config) ->
#             console.log data
#             return

#   templateUrl: '/client_views/container_standard.html'
# ]