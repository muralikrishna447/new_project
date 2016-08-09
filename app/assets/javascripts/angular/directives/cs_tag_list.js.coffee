@app.directive 'cstaglist', [() ->
  restrict: 'E',
  scope: { ngModel: "=" },
  templateUrl: '/client_views/_cs_tag_list'
]
