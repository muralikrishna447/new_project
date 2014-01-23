@app.controller 'SurveyController', ["$scope", ($scope) ->

  $scope.questions = []

  question1 = {}
  question1.type = 'select'
  question1.copy = 'What kind of cook are you?'
  question1.choices = ['Amatuer', 'Home Cook', 'Culinary Student', 'Professional Chef']
  $scope.questions.push(question1)

  question2 = {}
  question2.type = 'multiple-select'
  question2.copy = 'Select all that apply to you:'
  question2.choices = ['Vegetarian', 'Gluten-Free', 'Nut-Allergy']
  $scope.questions.push(question2)
  
]



