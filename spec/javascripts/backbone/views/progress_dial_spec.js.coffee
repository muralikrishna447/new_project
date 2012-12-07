describe 'ChefSteps.View.ProgressDial', ->
  beforeEach ->
    loadFixtures('progress_dial')
    @view = new ChefSteps.Views.ProgressDial(el: '[data-behavior~=progress-dial]')

  describe '#dialValue', ->
    it 'returns value as float', ->
      expect(@view.dialValue()).toEqual(0.0)

  describe '#dialMax', ->
    it 'returns max as float', ->
      expect(@view.dialMax()).toEqual(20.0)

  describe 'animate range', ->
    it 'sets animateStart to 0', ->
      @view.setAnimateRanges()
      expect(@view.animateStart).toEqual(0)

    it 'sets animateEnd to max when value is 0', ->
      $('input').val(0)
      @view.setAnimateRanges()
      expect(@view.animateEnd).toEqual(20)

    it 'sets animateEnd to val when value is > 0', ->
      $('input').val(5)
      @view.setAnimateRanges()
      expect(@view.animateEnd).toEqual(5)

  describe '#dialSize', ->
    beforeEach ->
      @setupWindowSize = (view, width)=>
        @spy ||= spyOn(view, 'windowSize')
        @spy.andReturn(width)

    it 'returns large for width >= 1200', ->
      @setupWindowSize(@view, 1200)
      expect(@view.dialSize()).toEqual('large')

    it 'returns medium for width < 1200 and width > 520', ->
      @setupWindowSize(@view, 1199)
      expect(@view.dialSize()).toEqual('medium')
      @setupWindowSize(@view, 521)
      expect(@view.dialSize()).toEqual('medium')

    it 'returns small for width <= 480', ->
      @setupWindowSize(@view, 520)
      expect(@view.dialSize()).toEqual('small')
