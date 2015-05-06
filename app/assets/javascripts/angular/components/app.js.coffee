@components = angular.module 'cs.components', []

@componentsManager = angular.module 'ComponentsManager', ['ui.router', 'ngResource', 'cs.components']

@componentsManager.config ['$locationProvider', ($locationProvider) ->

  $locationProvider.html5Mode(true)
  # $locationProvider.hashPrefix()
]

@componentsManager.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->

  $urlRouterProvider.otherwise('/components')

  $stateProvider
    .state 'components'
      abstract: true
      url: '/components'
      template: '<ui-view></ui-view>'

    .state 'components.index'
      url: ''
      controller: 'ComponentsIndexController'
      controllerAs: 'components'
      templateUrl: '/client_views/components_index.html'

    .state 'components.new'
      url: '/new'
      controller: 'ComponentsNewController'
      controllerAs: 'component'
      templateUrl: '/client_views/components_new.html'

    .state 'components.edit'
      url: '/edit/:id'
      controller: 'ComponentsEditController'
      controllerAs: 'component'
      templateUrl: '/client_views/components_edit.html'
]
