describe 'ChefSteps.Views.Question', ->
  beforeEach ->
    $.fx.off = true

    setStyleFixtures('.btn-next {display: block}')
    setFixtures(sandbox())
    @model = {id: 123}
    @model.toJSON = -> {}
    @view = new ChefSteps.Views.Question(model: @model)
    @view.extendTemplateJSON = ()->
      options: [
        { uid: 'ABCD', answer: 'true' }
      ]
    $('#sandbox').html(@view.render().$el)

  describe '#showNext', ->
    it 'shows next button', ->
      $('.btn-next').hide()
      @view.showNext()
      expect($('.btn-next')).toBeVisible()

  describe '#hideNext', ->
    it 'hides next button', ->
      setStyleFixtures('.btn-next {display: block}')
      @view.hideNext()
      expect($('.btn-next')).not.toBeVisible()

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

  describe '#submitAnswer', ->
    beforeEach ->
      spyOn(@view, 'answerData').andReturn('data')
      @answer = jasmine.createSpyObj('answer', ['save'])
      spyOn(ChefSteps.Models, 'Answer').andReturn(@answer)

    it 'creates answer with question_id', ->
      @view.submitAnswer()
      expect(ChefSteps.Models.Answer).toHaveBeenCalledWith(question_id: 123)

    it 'saves answer with data', ->
      @view.submitAnswer()
      expect(@answer.save).toHaveBeenCalledWith('data', jasmine.any(Object))

  describe '#submitSuccess', ->
    it "calls #next event on model's collection", ->
      @model.collection = jasmine.createSpyObj('collection', ['next'])
      @view.submitSuccess()
      expect(@model.collection.next).toHaveBeenCalled()
