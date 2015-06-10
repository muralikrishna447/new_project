@componentsManager.controller 'ComponentsIndexController', ['$http', ($http) ->
  @index = []
  $http.get('/api/v0/components').success (data, status, headers, config) =>
    @index = data
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

@componentsManager.controller 'ComponentsFormController', ['Component', '$stateParams', '$state', 'notificationService', 'AlgoliaSearchService', 'componentItemService', '$location', (Component, $stateParams, $state, notificationService, AlgoliaSearchService, componentItemService, $location) ->
  @typeOptions = ['single', 'matrix', 'madlib']
  @sizeOptions = ['full', 'small', 'medium', 'large']
  @itemTypes = componentItemService.types
  @colorOptions = ['white', 'black']
  @searchResults = []
  @toggleObject = {}

  console.log "$state.current.name: ", $state.current.name
  if $state.current.name == 'components.edit'
    console.log 'current name is component edit!'
    Component.show {id: $stateParams.id}, (component) =>
      @form = component
      @setNumItems()

  if $state.current.name == 'components.new'
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
        custom: {
          items: []
        }
        itemTypeName: null
      }
      name: null
    }
    @form.name = $location.search().name

  @save = (component) ->
    if $state.current.name == 'components.edit'
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

    if $state.current.name == 'components.new'
      $http.post('/api/v0/components', {component: component}).success (data, status, headers, config) ->
        $state.go('components.index')

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
        custom: {
          items: []
        }
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
    console.log 'set items'
    @numItems = @form.metadata.columns*@form.metadata.rows
    delta = @numItems - @form.metadata.custom.items.length
    struct = componentItemService.getStruct(@form.metadata.itemTypeName)

    if delta > 0
      i = 0
      while i < delta
        newStruct = angular.copy struct
        @form.metadata.custom.items.push { content: newStruct }
        i++

  @setItemType = ->
    struct = componentItemService.getStruct(@form.metadata.itemTypeName)
    items = @form.metadata.custom.items
    angular.forEach items, (item) ->
      oldItem = angular.copy item
      item.content = angular.copy struct
      angular.forEach item.content, (value,key) ->
        item.content[key] = oldItem.content[key]


  return this
]
