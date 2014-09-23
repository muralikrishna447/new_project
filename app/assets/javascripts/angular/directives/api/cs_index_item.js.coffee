@app.directive 'csIndexItem', [ ->
  restrict: 'E'
  scope: {
    title: '='
    url: '='
    image: '='
  }

  link: (scope, element, attrs) ->
    # console.log 'cs index item loaded'

  template: """
    <a ng-href="{{url}}">
      <div style='width:300px'>
        {{title}}
        <cs-image url='image'>
      </div>
    </a>
  """

]