@app.controller 'SurveyModalController', ['$scope', '$http', '$modal', '$rootScope', ($scope, $http, $modal, $rootScope) ->
  unbind = {}
  unbind = $rootScope.$on 'openSurvey', (event, data) ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_survey.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      resolve:
        afterSubmit: ->
          'openRecommendations'
        intent: ->
          if data
            data.intent
      controller: 'SurveyController'
    )
    mixpanel.track('Survey Opened')

  $scope.$on('$destroy', unbind)
]

@app.controller 'SurveyController', ['$scope', '$http', ($scope, $http) ->

  @options = [
    {
      name: 'Sous Vide'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/VO5w9ZlJQzSuY39wVjCA/convert?fit=crop&h=600&w=600&quality=90&cache=true'
    }
    {
      name: 'Kitchen Tips'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/zGFKehokRquV2wqanIj0/convert?fit=crop&h=600&w=600&quality=90&cache=true'
    }
    {
      name: 'Traditional Cooking'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/xiojrYF1QAemQ0ybBTbl/convert?fit=crop&h=600&w=600&quality=90&cache=true'
    }
    {
      name: 'Modern Cooking'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/eXkRnCTNSlKqLwIYYr4n/convert?fit=crop&h=600&w=600&quality=90&cache=true'
    }
    {
      name:'Beverages'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/4kMxDcRFTGmaa55Ro7M5/convert?fit=crop&h=600&w=600&quality=90&cache=true'
    }
    {
      name: 'Baking'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/ykypDm7TbnEga0m5D9AQ/convert?fit=crop&h=600&w=600&quality=90&cache=true'
    }
  ]

  @suggestion = ""

  @showDone = ->
    checks = @options.map (option) -> option.checked
    if _.contains(checks, true)
      return true
    else if @suggestion.length > 0
      return true
    else
      return false

  @done = ->
    survey_results = {}
    survey_results.interests = []
    survey_results.suggestion = @suggestion
    @options.map (option) ->
      if option.checked
        survey_results.interests.push option.name
    data = { survey_results: survey_results }
    $http.post('/user_surveys', data).success (data) ->
      console.log 'Saved data:', data

  return this
]

@app.directive 'csSurveyModal', [ ->
  restrict: 'E'
  controller: 'SurveyController'
  controllerAs: 'survey'
  link: (scope, element, attrs) ->
  templateUrl: '/client_views/_survey.html'
]


