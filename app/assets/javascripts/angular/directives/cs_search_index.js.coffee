@app.directive 'cssearchindex', ['api.search', 'api.activity', (Search, Activity) ->
  restrict: 'E'
  scope: { 
    query: '@'
  }

  link: (scope, element, attrs) ->
    parsed = JSON.parse(scope.query)
    scope.results = Activity.query(parsed)

  template: """
    <div ng-repeat='result in results'>
      <cs-index-item class='cs-index-item' title='result.title' url='result.url' image='result.image' difficulty='result.difficulty' likes-count='result.likesCount'>
      </cs-index-item>
    </div>
  """
]