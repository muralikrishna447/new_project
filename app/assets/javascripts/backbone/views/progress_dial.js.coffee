class ChefSteps.Views.ProgressDial extends Backbone.View
  initialize: (options)->
    @setAnimateRanges()
    @$el.parent('.dial-wrapper').show()
    @$el.val(0)
    @$el.knob()
    setTimeout(@animateDial, 2000)

  animateDial: =>
    step = 0.2
    stepDelay = 5
    if @dialValue() < @animateEnd
      @$el.val(@dialValue() + step).trigger('change')
      setTimeout(@animateDial, stepDelay)

  setAnimateRanges: ->
    @animateStart = 0
    @animateEnd = if @dialValue() > 0 then @dialValue() else @dialMax()

  dialValue: ->
    parseFloat(@$el.val())

  dialMax: ->
    parseFloat(@$el.data('max'))
