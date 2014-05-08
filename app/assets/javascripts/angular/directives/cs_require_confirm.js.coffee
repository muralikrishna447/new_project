@app.directive 'csRequireConfirm', ["$modal", ($modal) ->
  restrict: 'A'
  scope: { message: "@", action: "&"},

  link: (scope, element, attrs) ->
    savedAction = scope.action

    element.on  'click', ->
      $modal.open(
        backdrop: true
        template: '''
            <div class="modal-header">
              <h4>{{message}}</h4>
            </div>
            <div class="modal-footer">
              <div class="btn-toolbar">
                <div class="btn-group">
                  <div class="btn-primary btn" ng-click='doAction()'>
                    Do it!  
                  </div>
                </div>
                <div class="btn-group">
                  <div class="btn-secondary btn" ng-click='$dismiss("close")'>
                    Cancel               
                  </div>
                </div>
              </div>
            </div>
          '''
          
        controller: ["$scope", "$modalInstance", ($scope, $modalInstance) ->
          $scope.message = attrs.message
          $scope.doAction = ->
            savedAction()
            $scope.$close('done')
        ]
      )      
]