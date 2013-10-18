angular.module('ChefStepsApp').directive 'cssetiframeheight', ["$window", ($window) ->
  restrict: 'A'
  controller: ['$scope', '$window', ($scope, $window) ->

  ]

  link: (scope, elem, attrs) ->
    scope.setHeight = ->
      console.log 'hello'
      iframe = elem[0]
      console.log iframe.height
      iframe.height = iframe.contentWindow.document.body.scrollHeight + "px"

    scope.setHeight()
]