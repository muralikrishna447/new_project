@app.directive 'csIcon', [ ->
  replace: true
  restrict: 'A'
  scope: {
    csIcon: '@'
  }
  link: (scope, element, attrs, csAbtest) ->
    scope.icon = {}

    icon = [{"id":"code","width":"22px","height":"11.3px"},{"id":"comment-add","width":"22px","height":"23.4px"},{"id":"comment","width":"22px","height":"23.4px"},{"id":"edit-a-copy","width":"19.8px","height":"17.5px"},{"id":"edit","width":"20.6px","height":"21.5px"},{"id":"facebook","width":"11.4px","height":"22px"},{"id":"google+","width":"20px","height":"20px"},{"id":"mail","width":"29px","height":"21px"},{"id":"more","width":"19.1px","height":"4px"},{"id":"pinterest","width":"20px","height":"20px"},{"id":"print","width":"21.1px","height":"25px"},{"id":"saved","width":"13.5px","height":"27px"},{"id":"share","width":"22px","height":"22px"},{"id":"twitter","width":"27.1px","height":"22px"}]

    scope.icon = _.where(icon, {id: scope.csIcon})[0]
    scope.icon.href = '#icon-' + scope.icon.id

  template:
    """
      <svg class="csicon" ng-attr-width="{{icon.width}}" ng-attr-height="{{icon.height}}">
        <use xlink:href="{{icon.href}}"></use>
      </svg>
    """
]