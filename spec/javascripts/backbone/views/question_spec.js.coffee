describe 'ChefSteps.Views.Question', ->
  beforeEach ->
    $.fx.off = true

    setStyleFixtures('.btn-next {display: block}')
    setFixtures(sandbox())
    @view = new ChefSteps.Views.Question(model: @model)
    @view.extendTemplateJSON = ()->
      options: [
        { answer: 'A' }
      ]
    $('#sandbox').html(@view.render().$el)

  describe '#show', ->
    it 'creates the checkbox views', ->
      spyOn(@view, 'createCheckboxes')
      @view.show()
      expect(@view.createCheckboxes).toHaveBeenCalled()

    it 'sets the visible class', ->
      @view.show()
      expect(@view.$el).toHaveClass('visible')

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

