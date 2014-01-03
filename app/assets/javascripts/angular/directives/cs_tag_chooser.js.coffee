@app.directive 'cstagchooser', ['csTagService', (csTagService) ->
  restrict: 'E',
  scope: { options: "=", ngModel: "="},
  templateUrl: '/client_views/_cs_tag_chooser'
  link: ($scope) ->
    $scope.csTagService = csTagService
]
