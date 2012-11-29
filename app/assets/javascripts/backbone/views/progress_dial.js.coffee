class ChefSteps.Views.ProgressDial extends Backbone.View
  initialize: (options)->
    @$dial = @$('input.dial')

    @setAnimateRanges()
    @$el.show()
    @$dial.val(0)
    @$dial.knob()
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
