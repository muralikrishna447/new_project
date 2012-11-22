describe 'ChefStepsAdmin.Views.Questions', ->
  beforeEach ->
    loadFixtures('question_list')
    @collection = new ChefStepsAdmin.Collections.Questions([{id: 1}, {id: 2}])
    @view = new ChefStepsAdmin.Views.Questions(collection: @collection)

  describe '#render', ->
    it 'returns reference to self for chaining', ->
      expect(@view.render()).toEqual(@view)

    it 'adds question html to to list view', ->
      @view.render()
      expect($('ul#question-list li').length).toEqual(2)
