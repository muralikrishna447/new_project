@app.directive 'cscontenteditable', [() ->
  restrict: 'EAC',
  scope: { editMode: "=", ngModel: "="},
  templateUrl: '/client_views/_cs_contenteditable'
]
