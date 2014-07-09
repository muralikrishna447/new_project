@app.directive 'csglobalmessage', ["SiteSettings", (SiteSettings) ->
  restrict: 'E'
  link: (scope, element, attrs) ->
    SiteSettings.getSettings().then (data) ->
      scope.settings = data

  template: "<div class='global-message' ng-if='settings.global_message_active'>{{settings.global_message}}</div>"
]