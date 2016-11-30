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

@app.controller 'SurveyController', ['$scope', '$http', '$timeout', 'csAuthentication', ($scope, $http, $timeout, csAuthentication) ->
  @showSurvey = false
  @showRecommendations = false
  @showSuggestionMessage = false
  @recommendations = []

  @options = [
    {
      name: 'Sous Vide'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/VO5w9ZlJQzSuY39wVjCA/convert?fit=crop&h=600&w=600&quality=90&cache=true'
      imageLoaded: false
    }
    {
      name: 'Kitchen Tips'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/zGFKehokRquV2wqanIj0/convert?fit=crop&h=600&w=600&quality=90&cache=true'
      imageLoaded: false
    }
    {
      name: 'Traditional Cooking'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/xiojrYF1QAemQ0ybBTbl/convert?fit=crop&h=600&w=600&quality=90&cache=true'
      imageLoaded: false
    }
    {
      name: 'Modern Cooking'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/eXkRnCTNSlKqLwIYYr4n/convert?fit=crop&h=600&w=600&quality=90&cache=true'
      imageLoaded: false
    }
    {
      name:'Beverages'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/4kMxDcRFTGmaa55Ro7M5/convert?fit=crop&h=600&w=600&quality=90&cache=true'
      imageLoaded: false
    }
    {
      name: 'Baking'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/ykypDm7TbnEga0m5D9AQ/convert?fit=crop&h=600&w=600&quality=90&cache=true'
      imageLoaded: false
    }
    {
      name: 'Behind the Scenes'
      checked: false
      image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/dvc519Tk2h97xIdwj5hg/convert?fit=crop&h=600&w=600&quality=90&cache=true'
      imageLoaded: false
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

  @done = =>
    survey_results = {}
    survey_results.interests = []
    survey_results.suggestion = @suggestion
    @options.map (option) ->
      if option.checked
        survey_results.interests.push option.name
    data = { survey_results: survey_results }
    mixpanel.track('Survey Answered', survey_results)

    $http.post('/user_surveys', data)

    searchTerms = survey_results.interests
    searchTerms.push survey_results.suggestion if survey_results.suggestion?.length > 0
    searchParams = {
      tags: searchTerms.join(',')
      per: 8
    }

    $http.get('/api/v0/recommendations', {params: searchParams}).then (response) =>
      recommendations = response.data.map (r) ->
        image = r.image + '/convert?fit=crop&h=600&w=600&quality=90&cache=true'
        r.image = image
        return r
      @recommendations = recommendations
      @showSurvey = false

      if @recommendations.length > 0
        @showRecommendations = true
      else if @recommendations.length == 0 && survey_results.suggestion
        @showSuggestionMessage = true
      console.log 'recommendations: ', @recommendations

  @updateStatus = (option) =>
    that = this
    option.imageLoaded = true
    imageLoadedArray = @options.map (option) -> option.imageLoaded
    if _.contains(imageLoadedArray, false)
      @showSurvey = false
    else
      $timeout(->
        that.showSurvey = true
      , 100)

  return this
]

@app.directive 'csSurveyModal', [ ->
  restrict: 'E'
  controller: 'SurveyController'
  controllerAs: 'survey'
  link: (scope, element, attrs) ->
  templateUrl: '/client_views/_survey.html'
]

@app.directive 'imageonload', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element.bind 'load', ->
      scope.$apply attrs.imageonload
