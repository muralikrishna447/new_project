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

