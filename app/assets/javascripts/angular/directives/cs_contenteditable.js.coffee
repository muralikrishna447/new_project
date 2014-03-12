@app.directive 'csContenteditable', [() ->
  restrict: 'A',
  require: "?ngModel"
  scope: {  placeholder: "=", ngModel: "=", editMode: "=csContenteditable", creator: "="},
  templateUrl: '/client_views/_cs_contenteditable'
  controller: ["$scope", "$sce", "$filter", ($scope, $sce, $filter) ->
    $scope.runFilters = (input) ->
      input = $filter('markdown')($filter('shortcode')(input))
      # Only if creator is chefsteps
      input = $sce.trustAsHtml(input) if $scope.creator == null
      input
  ]
]
