describe 'ChefStepsAdmin.Collections.Questions', ->
  beforeEach ->
    @collection = new ChefStepsAdmin.Collections.Questions([], quizId: 'test')

  it 'uses quizId in url', ->
    expect(@collection.url()).toEqual('/admin/quizzes/test/questions')

