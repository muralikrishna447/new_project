@app.controller 'HomeManagerController', ['$scope', ($scope) ->
  @content = []
  @add = (container) ->
    @content.push container
    container = {}
    console.log @content

  @new = ->
    console.log 'Adding New item'
    @content.push {containerType: 'hero', formState: 'new'}
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
    @form.containerType = @containerType.name

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

@app.controller 'ExampleController', ['$scope', ($scope) ->

  @formData = {
    containerType: 'hero'
    mode: 'api'
    source: 'http://localhost:3000/api/v0/activities/2434'
    buttonMessage: 'Hello'
    targetURL: 'hey'
  }

  @mode = ''

  return this
]

@app.directive 'csHeroForm', [ ->
  restrict: 'A'
  scope: {
    formData: '='
    formState: '='
  }
  link: (scope, element, attrs) ->
    # console.log 'scope from csHeroForm', scope

    scope.creator = {}
    scope.creator.form = scope.formData

    scope.toggle = ->
      if scope.formState == 'edit'
        scope.formState = ''
      else if scope.formState == 'new'
        scope.formState = ''
      else
        scope.formState = 'edit'
  templateUrl: '/client_views/cs_hero_form.html'
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

