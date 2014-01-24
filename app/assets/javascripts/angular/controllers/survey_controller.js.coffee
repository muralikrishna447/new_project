@app.controller 'SurveyController', ['$scope', '$http', ($scope, $http) ->

  $scope.questions = []
  $scope.survey_results = {}

  question1 = {}
  question1.type = 'select'
  question1.copy = 'What kind of cook are you?'
  question1.options = ['Amatuer', 'Home Cook', 'Culinary Student', 'Professional Chef']
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

  $scope.update = ->
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
    
    data = {'survey_results': $scope.survey_results}
    $http.post('/user_surveys', data).success(
      console.log 'successfully update survey'
    )
]



