@app.controller 'SurveyController', ['$scope', '$http', '$modal', ($scope, $http, $modal) ->

  $scope.open = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_survey.html"
      backdrop: false
      keyboard: false
      # windowClass: "takeover-modal"
      windowClass: "modal-fullscreen"
      controller: 'SurveyModalController'
    )
    mixpanel.track('Survey Opened')
]

@app.controller 'SurveyModalController', ['$scope', '$modalInstance', '$http', 'csAuthentication', ($scope, $modalInstance, $http, csAuthentication) ->
  $scope.currentUser = csAuthentication.currentUser()
  $scope.questions = []
  if $scope.currentUser && $scope.currentUser.survey_results
    $scope.survey_results = $scope.currentUser.survey_results
  else
    $scope.survey_results = []
  
  question1 = {}
  question1.type = 'select'
  question1.copy = 'What kind of cook are you?'
  question1.searchScope = 'difficulty'
  question1.options = ['Amateur', 'Home Cook', 'Culinary Student', 'Professional']
  $scope.questions.push(question1)

  question2 = {}
  question2.type = 'multiple-select'
  question2.copy = 'Dietary Restrictions. Select all that apply to you:'
  question2.options = [
    {
      name: 'Vegetarian'
      checked: false
    }
    {
      name: 'Gluten-Free'
      checked: false
    }
    {
      name:'Nut-Allergy'
      checked: false
    }
  ]
  $scope.questions.push(question2)

  question3 = {}
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
  question5.type = 'open-ended'
  question5.copy = 'Tell us more about yourself:'
  $scope.questions.push(question5)

  $scope.loadResults = ->
    angular.forEach $scope.questions, (question, index) ->
      surveyResult = _.where($scope.survey_results, {copy: question.copy})
      # questionCopy = $scope.survey_results[question.copy]
      if surveyResult
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
          # $scope.survey_results[question.copy] = question.answer
          survey_result.answer = question.answer
        when 'multiple-select'
          answers = [] 
          angular.forEach question.options, (option, index) ->
            if option.checked
              answers.push(option.name)
          # $scope.survey_results[question.copy] = answers.join()
          survey_result.answer = answers.join()
        when 'open-ended'
          # $scope.survey_results[question.copy] = question.answer
          survey_result.answer = question.answer
      $scope.survey_results.push(survey_result)
    $scope.currentUser.survey_results = $scope.survey_results

  $scope.update = ->
    $scope.getResults()
    mixpanel.track('Survey Answered', $scope.survey_results)

    data = {'survey_results': $scope.survey_results}
    $http.post('/user_surveys', data).success((data) ->
      $modalInstance.close()
    )

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

  if $scope.currentUser
    $scope.loadResults()
]


