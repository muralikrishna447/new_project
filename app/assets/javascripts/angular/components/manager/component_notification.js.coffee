@componentsManager.service 'notificationService', [ ->

  @notifications = []

  @add = (status, message, buttonUrl, buttonText) =>
    console.log "adding: ", message
    @notifications.push {status: status, message: message, buttonUrl: buttonUrl, buttonText: buttonText}

  return this
]

@componentsManager.directive 'notifications', ['notificationService', (notificationService) ->
  restrict: 'A'
  scope: {}

  link: (scope, element, attrs) ->
    scope.notifications = notificationService.notifications

  # templateUrl: '/client_views/component_mapper.html'
  template:
    """
      <div class='notifications'>
        <div ng-repeat='notification in notifications' class='notification'>
          <div class='notification-message'>{{notification.message}}</div>
          <a class='btn btn-primary notification-button' ng-href='{{notification.buttonUrl}}'>
            {{notification.buttonText}}
          </a>
        </div>
      </div>
    """
]
