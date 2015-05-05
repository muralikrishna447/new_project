@componentsManager = angular.module 'ComponentsManager', ['ui.router']

@componentsManager.config ['$locationProvider', ($locationProvider) ->
  console.log '$locationProvider loaded'
  $locationProvider.html5Mode(true)
  # $locationProvider.hashPrefix()
]

@componentsManager.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->
  console.log '$stateProvider loaded'
  $urlRouterProvider.otherwise("/components")

  $stateProvider
    .state 'components'
      url: '/components'
      controller: 'ComponentsController'
      controllerAs: 'manager'
      templateUrl: '/client_views/components_manager.html'

]
