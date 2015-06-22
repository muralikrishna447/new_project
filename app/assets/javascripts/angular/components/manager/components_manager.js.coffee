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

@componentsManager.controller 'ComponentsFormController', ['Component', '$stateParams', '$state', 'notificationService', 'AlgoliaSearchService', 'componentItemService', '$location', '$rootScope', '$scope', (Component, $stateParams, $state, notificationService, AlgoliaSearchService, componentItemService, $location, $rootScope, $scope) ->
  @typeOptions = ['feed', 'madlib','matrix']
  @sizeOptions = ['full', 'standard', 'small']
  @themeOptions = ['light', 'dark']
  @itemTypes = componentItemService.types
  @colorOptions = ['white', 'black']
  @searchResults = []
  @toggleObject = {}
  @unsavedUpdates = false

  componentStruct = {
    componentType: null
    meta: {
      itemTypeName: null
      items: []
      size: 'standard'
      theme: null
    }
    name: null
  }

  if $state.current.name == 'components.edit'
    console.log 'current name is component edit!'
    Component.show {id: $stateParams.id}, (component) =>
      @form = component
      @setNumItems()

  if $state.current.name == 'components.new'
    @form = componentStruct
    @form.name = $location.search().name

  # Adds item to the top
  @addItem = ->
    struct = componentItemService.getStruct(@form.meta.itemTypeName)
    newStruct = angular.copy struct
    @form.meta.items.unshift({content: newStruct})

  @save = (component) =>
    if $state.current.name == 'components.edit'
      componentParams = component
      delete componentParams['id']
      delete componentParams['slug']
      # console.log 'componentParams: ', componentParams
      Component.update {id: $stateParams.id, component: componentParams}, ((component) =>
        @unsavedUpdates = false
        $state.go('components.index')
        # console.log 'component: ', component
        message = "The #{component.name } component was successfully saved. "
        buttonUrl = "/components/#{component.id}/edit"
        buttonText = "Edit #{component.name}"
        notificationService.add('success', message, buttonUrl, buttonText)
      ), (error) ->
        console.log 'Error while saving: ', error

    if $state.current.name == 'components.new'
      Component.create {id: $stateParams.id, component: component}, ((component) =>
        $state.go('components.index')
      ), (error) ->
        console.log 'Error while saving: ', error

  @clear = =>
    @form = componentStruct

  @setItem = (selectedItem, componentItem) ->
    angular.forEach componentItem.content, (value, key) ->
      if selectedItem.hasOwnProperty(key)
        componentItem.content[key] = selectedItem[key]

  @numItems = 0

  @setNumItems = =>
    console.log 'set items'
    @numItems = @form.meta.columns*@form.meta.rows
    delta = @numItems - @form.meta.items.length
    struct = componentItemService.getStruct(@form.meta.itemTypeName)

    # If there are not enough items, then add new items
    if delta > 0
      i = 0
      while i < delta
        newStruct = angular.copy struct
        @form.meta.items.push { content: newStruct }
        i++

    # Only keep the items needed
    if delta < 0
      @form.meta.items = @form.meta.items.slice(0,@numItems)

  @setItemType = ->
    struct = componentItemService.getStruct(@form.meta.itemTypeName)
    items = @form.meta.items
    angular.forEach items, (item) ->
      oldItem = angular.copy item
      item.content = angular.copy struct
      angular.forEach item.content, (value,key) ->
        item.content[key] = oldItem.content[key]

  # If there are changes to the form, set unsavedUpdates to true
  $scope.$watch angular.bind(this, => @form), ((newValue, oldValue) =>
    if newValue && typeof oldValue != 'undefined'
      @unsavedUpdates = true
  ), true

  # Warn the user if there are leaving the page and there are unsaved changes
  $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) =>
    if toState.name != $state.current.name
      if @unsavedUpdates
        @confirm = confirm "You have unsaved changes.  Click 'OK' to leave this page without saving."
        if @confirm
          @unsavedUpdates = false
          $state.go(toState.name)
        e.preventDefault()
  return this
]
