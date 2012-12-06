class ChefSteps.Views.ProgressDial extends Backbone.View
  initialize: (options)->
    @setSize() unless options.noAdjustSize

    @$dial = @$('input')

    @setAnimateRanges()
    @$el.show()
    @$dial.val(0)
    @$dial.knob(
      width: @$el.width(),
      height: @$el.height()
    )
    setTimeout(@animateDial, 2000)

  animateDial: =>
    step = 0.2
    stepDelay = 5
    if @dialValue() < @animateEnd
      @$dial.val(@dialValue() + step).trigger('change')
      setTimeout(@animateDial, stepDelay)

  setAnimateRanges: ->
    @animateStart = 0
    @animateEnd = if @dialValue() > 0 then @dialValue() else @dialMax()

  dialValue: ->
    parseFloat(@$dial.val())

  dialMax: ->
    parseFloat(@$dial.data('max'))

  windowSize: ->
    $(window).width()

  dialSize: ->
    return 'large' if @windowSize() >= 1200
    return 'small' if @windowSize() <= 520
    return 'medium'

  setSize: ->
    @$el.addClass(@dialSize())
