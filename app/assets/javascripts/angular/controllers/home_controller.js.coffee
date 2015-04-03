@app.controller 'HomeManagerController', ['$scope', ($scope) ->
  @content = []
  @showAddMenu = false

  @addToggle = ->
    @showAddMenu = ! @showAddMenu

  @add = (containerType) ->
    @content.push {containerType: containerType, formState: 'new'}
    @showAddMenu = false

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

  @example = {
    containerType: 'hero'
    mode: 'api'
    source: 'http://localhost:3000/api/v0/activities/2434'
    buttonMessage: 'Hello'
    targetURL: 'hey'
  }

  return this

]

@app.directive 'csContainerForm', [ ->
  restrict: 'A'
  scope: {
    formData: '='
    formState: '='
  }
  link: (scope, element, attrs) ->

    scope.creator = {}
    scope.creator.form = scope.formData

    scope.includePreview = (containerType) ->
      return "/client_views/container_#{containerType}.html"

    scope.includeForm = (containerType) ->
      return "/client_views/container_#{containerType}_form.html"

    scope.toggle = ->
      if scope.formState == 'edit'
        scope.formState = ''
      else if scope.formState == 'new'
        scope.formState = ''
      else
        scope.formState = 'edit'
  templateUrl: '/client_views/cs_container_form.html'
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
    csStandard: '@'
  }
  link: (scope, $element, $attrs) ->
    scope.content = {}
    scope.$watch 'csStandard', (newValue, oldValue) ->
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

