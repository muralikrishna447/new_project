@app.directive 'csContenteditable', [() ->
  restrict: 'A',
  require: "?ngModel"
  scope: { ngModel: "=", editMode: "=csContenteditable"},
  templateUrl: '/client_views/_cs_contenteditable'
]
