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

@app.controller 'SurveyController', ['$scope', '$http', 'csAuthentication', '$rootScope', ($scope, $http, csAuthentication, $rootScope) ->
  $scope.currentUser = csAuthentication.currentUser()
  $scope.questions = []
  if $scope.currentUser && $scope.currentUser.survey_results
    $scope.survey_results = $scope.currentUser.survey_results
  else
    $scope.survey_results = []
  
  question1 = {}
  question1.slug = 'Skill Level'
  question1.type = 'select'
  question1.copy = 'What kind of cook are you?'
  question1.searchScope = 'difficulty'
  question1.options = ['Amateur', 'Home Cook', 'Culinary Student', 'Professional']
  $scope.questions.push(question1)

  # question2 = {}
  # question2.type = 'multiple-select'
  # question2.copy = 'Dietary Restrictions. Select all that apply to you:'
  # question2.options = [
  #   {
  #     name: 'Vegetarian'
  #     checked: false
  #   }
  #   {
  #     name: 'Gluten-Free'
  #     checked: false
  #   }
  #   {
  #     name:'Nut-Allergy'
  #     checked: false
  #   }
  # ]
  # $scope.questions.push(question2)

  question3 = {}
  question3.slug = 'Interests'
  question3.type = 'multiple-select'
  question3.copy = 'Which culinary topics interest you the most?'
  question3.searchScope = 'interests'
  question3.options = [
    {
      name: 'Modernist Cuisine'
      checked: false
    }
    {
      name: 'Baking'
      checked: false
    }
    {
      name:'Butchering'
      checked: false
    }
    {
      name:'Food Science'
      checked: false
    }
  ]
  $scope.questions.push(question3)

  question4 = {}
  question4.slug = 'Equipment'
  question4.type = 'multiple-select'
  question4.copy = 'What equipment do you have in your kitchen?'
  question4.searchScope = 'by_equipment_title'
  question4.options = [
    {
      name: 'Blender'
      checked: false
    }
    {
      name: 'Immersion Blender'
      checked: false
    }
    {
      name:'Stand Mixer'
      checked: false
    }
    {
      name:'Pressure Cooker'
      checked: false
    }
    {
      name:'Immersion Circulator'
      checked: false
    }
    {
      name:'Whipping Siphon'
      checked: false
    }
  ]
  $scope.questions.push(question4)

  question5 = {}
  question5.slug = 'Bio'
  question5.type = 'open-ended'
  question5.copy = 'Tell us more about yourself:'
  $scope.questions.push(question5)

  $scope.loadResults = ->
    angular.forEach $scope.questions, (question, index) ->
      surveyResult = _.where($scope.survey_results, {copy: question.copy})
      if surveyResult.length > 0
        switch question.type
          when 'select'
            question.answer = surveyResult[0].answer
          when 'multiple-select'
            checked =  surveyResult[0].answer.split(',')
            angular.forEach question.options, (option, index) ->
              if checked.indexOf(option.name) != -1
                option.checked = true
          when 'open-ended'
            question.answer = surveyResult[0].answer

  $scope.getResults = ->
    $scope.survey_results = []
    angular.forEach $scope.questions, (question, index) ->
      survey_result = {}
      survey_result.copy = question.copy
      survey_result.search_scope = question.searchScope
      switch question.type
        when 'select'
          survey_result.answer = question.answer
          # mixpanel.people.set(question.slug, survey_result.answer)
        when 'multiple-select'
          answers = [] 
          angular.forEach question.options, (option, index) ->
            if option.checked
              answers.push(option.name)
          survey_result.answer = answers.join()
        when 'open-ended'
          survey_result.answer = question.answer
      $scope.survey_results.push(survey_result)
      console.log question.slug
      mixpanel.people.set(question.slug, survey_result.answer)
      console.log 'its set'
    $scope.currentUser.survey_results = $scope.survey_results

  $scope.update = ->
    $scope.getResults()
    mixpanel.track('Survey Answered', $scope.survey_results)

    data = {'survey_results': $scope.survey_results, 'location': $scope.location.input}
    $http.post('/user_surveys', data).success((data) ->

    )

  $scope.getPredictions = (input) ->
    url = "/locations/autocomplete?input=#{input}"
    console.log "URL IS: ", url
    $http.get(url).then (response) ->
      predictions = []
      angular.forEach response.data.predictions, (item) ->
        predictions.push(item.description)
      $scope.predictions = predictions

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

  if $scope.currentUser
    $scope.loadResults()

  $rootScope.$on 'closeSurveyFromFtue', ->
    $scope.update()
]

@app.directive 'csSurveyModal', [ ->
  restrict: 'E'
  controller: 'SurveyController'
  link: (scope, element, attrs) ->
  templateUrl: '/client_views/_survey.html'
]


