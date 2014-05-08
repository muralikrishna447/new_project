@app.directive 'csRequireConfirm', ["$modal", ($modal) ->
  restrict: 'A'
  scope: { message: "@", action: "&"}
  transclude: true

  link: (scope, element, attrs) ->

    scope.state = {}

    element.find('[ng-transclude]').on 'click', ->
      scope.state.modalShowing = true

    scope.doAction = ->
      scope.action()
      scope.state.modalShowing = false

    scope.close = ->
      scope.state.modalShowing = false
     

  template: '''
      <div class='cs-require-confirm-container'>
        <div ng-transclude/>
        <div class='cs-require-confirm-popup anim-basic-fade' ng-show="state.modalShowing">
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
                <div class="btn-secondary btn" ng-click='close()'>
                  Cancel               
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
  '''
    
]