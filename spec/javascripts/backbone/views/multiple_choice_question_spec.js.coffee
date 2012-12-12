describe 'ChefSteps.Views.MultipleChoiceQuestion', ->
  beforeEach ->
    setStyleFixtures('.btn-next {display: block}')
    setFixtures(sandbox())
    @model = {id: 123}
    @model.toJSON = -> {}
    @view = new ChefSteps.Views.MultipleChoiceQuestion(model: @model)
    @view.extendTemplateJSON = ()->
      options: [
        { uid: 'ABCD', answer: 'true' }
      ]
    $('#sandbox').html(@view.render().$el)

  describe '#answerSelected', ->
    it 'returns false if no inputs are checked', ->
      expect(@view.answerSelected()).toBe(false)

    it 'returns true if any inputs are checked', ->
      @view.$('input').attr('checked', true)
      expect(@view.answerSelected()).toBe(true)

  describe '#answerChanged', ->
    it 'hides next if no answer selected', ->
      spyOn(@view, 'hideNext')
      @view.answerSelected = -> false
      @view.answerChanged()
      expect(@view.hideNext).toHaveBeenCalled()

    it 'shows next if answer selected', ->
      spyOn(@view, 'showNext')
      @view.answerSelected = -> true
      @view.answerChanged()
      expect(@view.showNext).toHaveBeenCalled()

  describe '#answerData', ->
    beforeEach ->
      $('input').attr('checked', true)

    it "returns type of 'multiple_choice'", ->
      expect(@view.answerData().type).toEqual('multiple_choice')

    it 'returns uid for selected option', ->
      expect(@view.answerData().uid).toEqual('ABCD')

    it 'returns answer for selected option', ->
      expect(@view.answerData().answer).toEqual('true')
