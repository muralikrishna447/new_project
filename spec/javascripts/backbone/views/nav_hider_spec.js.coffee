describe 'ChefSteps.Views.NavHider', ->
  beforeEach ->
    $.fx.off = true

    loadFixtures('layout')
    @$el = $('#container')
    @view = new ChefSteps.Views.NavHider(el: @$el)

  describe '#hide', ->
    beforeEach ->
      @view.hide()

    it 'hides the header and footer elements', ->
      expect(@view.$('#header')).not.toBeVisible()
      expect(@view.$('#footer')).not.toBeVisible()

  describe '#show', ->
    beforeEach ->
      @view.hide()
      @view.show()

    it 'shows the header and elements', ->
      expect(@view.$('#header')).toBeVisible()
      expect(@view.$('#footer')).toBeVisible()
