@app.directive 'csFetch', ["$injector", "csUtilities", ($injector, csUtilities) ->
  restrict: 'A'
  scope: { part: "@",  card: "="},
  replace: 'true'
  template: """
    <div class='nell-embed'>
      <div ng-if="part != 'null'" ng-model="fetched" cs-contenteditable="false"></div>
      <div ng-if="part == 'null'">
        <div ng-if="obj" ng-include="getCard()"></div>
        <div ng-if="! obj" ng-bind-html="loadingMessage"></div>
      </div>
    </div>
  """

  link: (scope, element, attrs) ->
    scope.csUtilities = csUtilities

    scope.loadingMessage = '''
      <h4 class='fetch-content-loading'>Loading...</h4>
    '''

    scope.getCard = ->
      attrs.card

    scope.fetched = scope.loadingMessage

    scope.reload = ->
      $injector.invoke([attrs.type, (resourceObject) ->
        resourceObject.get_as_json(
          {id: attrs.csFetch}
          (value) ->
            scope.obj = value
            if attrs.type == 'Activity'
              scope.objType = value.activity_type[0] || 'Recipe'
            else if attrs.type == 'Cuts'
              scope.objType = 'Cuts'

            scope.obj.hasVideo = value.youtube_id || value.vimeo_id
            if attrs.part? && attrs.part != "null"
              scope.fetched = scope.obj[attrs.part] || scope.obj.text_fields?[attrs.part] || ("<span style='color: red;'>ERROR: couldn't find section named '" + attrs.part + "'</span>")
          (error) ->
            error.data = "couldn't find #{attrs.type} with slug '#{attrs.csFetch}'" if error.status == 404
            scope.fetched = "<span style='color: red;'>ERROR (#{error.status}): #{error.data}</span>"
        )
      ])

    scope.$watch attrs.csFetch,  ->
      scope.reload()
]

@app.directive 'csFetchTool', [() ->
  restrict: 'A'
  scope: { csFetchTool: "@" },
  replace: 'true'
  template: """
    <div class='nell-embed'>
      <div ng-include="getTool()"></div>
    </div>
  """

  link: (scope, element, attrs) ->
    scope.getTool = ->
      scope.csFetchTool + '.html'
]