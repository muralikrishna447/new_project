describe 'ChefStepsAdmin.Router', ->
  beforeEach ->
    @router = new ChefStepsAdmin.Router()

  describe "routes", ->
    it "defines route and callback", ->
      expect(@router.routes).toEqual
        "/admin/quizzes/new" : "createQuiz"
        "/admin/quizzes/{id}/edit" : "editQuiz"

