@app.controller 'SurveyController', ["$scope", ($scope) ->

  $scope.questions = []

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

  $scope.update = ->
    console.log JSON.stringify($scope.questions)
]



