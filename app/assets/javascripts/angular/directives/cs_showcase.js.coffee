@app.directive 'csShowcase', ['$window', ($window) ->
  restrict: 'A'
  scope: {
    collection: '@'
  }
  controller: ($scope) ->
    if $scope.collection == 'knives'
      $scope.items = [
        {
          title: 'hello'
          description: 'this is the description'
          imageUrl: 'some image url'
          annotations: [
            {
              x: '30'
              y: '50'
              title: 'a1'
              description: 'description for a1'
              imageUrl: 'lksjd'
              price: '40.00'
            },
            {
              x: '10'
              y: '80'
              title: 'a2'
              description: 'description for a2'
              imageUrl: 'lksjd'
              price: '80.00'
            }
          ]
        }
      ]
  link: (scope, element, attrs) ->
    console.log 'csShowcase!'

  templateUrl: '/client_views/cs_showcase.html'

]