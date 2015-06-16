@componentsManager = angular.module 'ComponentsManager', ['ui.router', 'ngResource', 'cs.components', 'cs.api', 'cs.helpers']

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
      controller: 'ComponentsFormController'
      controllerAs: 'component'
      templateUrl: '/client_views/components_new.html'

    .state 'components.edit'
      url: '/:id/edit'
      controller: 'ComponentsFormController'
      controllerAs: 'component'
      templateUrl: '/client_views/components_edit.html'

    .state 'components.examples'
      url: '/examples'
      controller: 'ComponentsExamplesController'
      controllerAs: 'examples'
      templateUrl: '/client_views/components_examples.html'

    .state 'components.editExperimental'
      url: '/:id/edit-experimental'
      controller: 'ComponentsEditExperimentalController'
      controllerAs: 'component'
      templateUrl: '/client_views/components_edit_experimental.html'
]
