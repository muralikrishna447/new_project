@app.directive 'csContenteditable', [() ->
  restrict: 'A',
  scope: { ngModel: "=", editMode: "=csContenteditable"},
  templateUrl: '/client_views/_cs_contenteditable'
]
