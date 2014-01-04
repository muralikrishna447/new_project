@app.directive 'cstaglist', [() ->
  restrict: 'E',
  scope: { ngModel: "=", searchPath: "="},
  templateUrl: '/client_views/_cs_tag_list'
]
