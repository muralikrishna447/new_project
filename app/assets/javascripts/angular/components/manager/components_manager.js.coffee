@componentsManager.controller 'ComponentsIndexController', ['$http', ($http) ->
  @index = []
  $http.get('/api/v0/components').success (data, status, headers, config) =>
    @index = data
  return this
]

@componentsManager.controller 'ComponentsNewController', ['$http', '$state', '$location', ($http, $state, $location) ->

  @componentTypeOptions = ['single', 'matrix', 'madlib']
  @form = {
    componentType: null
    mode: null
    metadata: {
      allModes: {
        styles:
          component:
            size: 'full'
      }
      api: {}
      custom: {}
      itemTypeName: null
    }
    name: null
  }
  @form.name = $location.search().name # Would prefer to use $state, but since entire site isn't a single page app yet, we can't quite do this until we fix activities


  @save = (component) ->
    $http.post('/api/v0/components', {component: component}).success (data, status, headers, config) ->
      $state.go('components.index')

  return this
]

@componentsManager.controller 'ComponentsEditController', ['Component', '$stateParams', '$state', 'notificationService', (Component, $stateParams, $state, notificationService) ->
  @componentTypeOptions = ['single', 'matrix', 'madlib']
  @componentSizeOptions = ['full', 'small', 'medium', 'large']
  @colorOptions = ['white', 'black']

  Component.show {id: $stateParams.id}, (component) =>
    @form = component

  @save = (component) ->
    componentParams = component
    delete componentParams['id']
    delete componentParams['slug']
    Component.update {id: $stateParams.id, component: componentParams}, (component) ->
      $state.go('components.index')
      console.log 'component: ', component
      message = "The #{component.name } component was successfully saved. "
      buttonUrl = "/components/#{component.id}/edit"
      buttonText = "Edit #{component.name}"
      notificationService.add('success', message, buttonUrl, buttonText)

  @clear = =>
    @form = {
      componentType: null
      mode: null
      metadata: {
        allModes: {
          styles:
            component:
              size: 'full'
        }
        api: {}
        custom: {}
        itemTypeName: null
      }
      name: null
    }

  return this
]

@componentsManager.controller 'ComponentsExamplesController', [ ->
  exampleImage = 'https://d3awvtnmmsvyot.cloudfront.net/api/file/uoeCHDciQ7enMutU8ZKZ'

  @itemHeroA =
    content:
      title: 'Example Hero A'
      buttonMessage: 'Click Me!'
      image: exampleImage

  @itemListA =
    content:
      title: 'Example List A'
      description: 'This is an example List A component item'
      image: exampleImage

  @itemMediaA =
    content:
      title: 'Example Media A'
      description: 'This is an example Media A component item'
      image: exampleImage

  @itemSquareA =
    content:
      title: 'Example Square A'
      buttonMessage: 'Click me!'
      image: exampleImage

  @feedMapper = [
    {
      componentKey: "title",
      sourceKey: "title",
      value: ""
    },
    {
      componentKey: "image",
      sourceKey: "image",
      value: ""
    },
    {
      componentKey: "buttonMessage",
      sourceKey: null,
      value: "See the recipe"
    },
    {
      componentKey: "url",
      sourceKey: "url",
      value: ""
    }
  ]

  return this
]

@componentsManager.controller 'ComponentsEditExperimentalController', ['Component', '$stateParams', '$state', 'notificationService', 'AlgoliaSearchService', 'componentItemService', (Component, $stateParams, $state, notificationService, AlgoliaSearchService, componentItemService) ->
  @typeOptions = ['single', 'matrix', 'madlib']
  @sizeOptions = ['full', 'small', 'medium', 'large']
  @itemTypes = componentItemService.types
  @colorOptions = ['white', 'black']
  @searchResults = []

  Component.show {id: $stateParams.id}, (component) =>
    @form = component
    @setNumItems()

  @save = (component) ->
    componentParams = component
    delete componentParams['id']
    delete componentParams['slug']
    Component.update {id: $stateParams.id, component: componentParams}, (component) ->
      $state.go('components.index')
      console.log 'component: ', component
      message = "The #{component.name } component was successfully saved. "
      buttonUrl = "/components/#{component.id}/edit"
      buttonText = "Edit #{component.name}"
      notificationService.add('success', message, buttonUrl, buttonText)

  @clear = =>
    @form = {
      componentType: null
      mode: null
      metadata: {
        allModes: {
          styles:
            component:
              size: 'full'
        }
        api: {}
        custom: {}
        itemTypeName: null
      }
      name: null
    }

  @setItem = (selectedItem, componentItem) ->
    angular.forEach componentItem.content, (value, key) ->
      if selectedItem.hasOwnProperty(key)
        componentItem.content[key] = selectedItem[key]

  @numItems = 0
  @setNumItems = =>
    @numItems = @form.metadata.columns*@form.metadata.rows
    delta = @numItems - @form.metadata.custom.items.length
    console.log 'diff: ', delta
    if delta > 0
      newItemsToAdd = new Array(delta)
      for newItem in newItemsToAdd
        @form.metadata.custom.items.push {content:{}}

  return this
]
