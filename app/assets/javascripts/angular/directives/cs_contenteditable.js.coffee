@app.directive 'csContenteditable', [() ->
  restrict: 'A',
  require: "?ngModel"
  scope: {  placeholder: "=", ngModel: "=", editMode: "=csContenteditable", creator: "="},
  templateUrl: '_cs_contenteditable.html'
  controller: ["$scope", "$sce", "$filter", ($scope, $sce, $filter) ->
    $scope.runFilters = (input) ->
      input = $filter('markdown')($filter('shortcode')(input))
      input = $sce.trustAsHtml(input) if $scope.creator == null
      input
    
  ]
]
