@app.controller 'SurveyController', ['$scope', '$http', '$modal', ($scope, $http, $modal) ->

  $scope.open = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_survey.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      controller: 'SurveyModalController'
    )
    mixpanel.track('Survey Opened')
]

@app.controller 'SurveyModalController', ['$scope', '$modalInstance', '$http', 'csAuthentication', ($scope, $modalInstance, $http, csAuthentication) ->
  $scope.currentUser = csAuthentication.currentUser()
  $scope.questions = []
  if $scope.currentUser
    $scope.survey_results = $scope.currentUser.survey_results
  else
    $scope.survey_results = {}
  
  question1 = {}
  question1.type = 'select'
  question1.copy = 'What kind of cook are you?'
  question1.options = ['Amateur', 'Home Cook', 'Culinary Student', 'Professional Chef']
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
  question4.type = 'open-ended'
  question4.copy = 'Tell us more about yourself:'
  $scope.questions.push(question4)

  $scope.loadResults = ->
    angular.forEach $scope.questions, (question, index) ->
      switch question.type
        when 'select'
          question.answer = $scope.survey_results[question.copy]
        when 'multiple-select'
          checked =  $scope.survey_results[question.copy].split(',')
          angular.forEach question.options, (option, index) ->
            if checked.indexOf(option.name) != -1
              option.checked = true
        when 'open-ended'
          question.answer = $scope.survey_results[question.copy]

  $scope.getResults = ->
    angular.forEach $scope.questions, (question, index) ->
      switch question.type
        when 'select'
          $scope.survey_results[question.copy] = question.answer
        when 'multiple-select'
          answers = [] 
          angular.forEach question.options, (option, index) ->
            if option.checked
              answers.push(option.name)
          $scope.survey_results[question.copy] = answers.join()
        when 'open-ended'
          $scope.survey_results[question.copy] = question.answer    

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


